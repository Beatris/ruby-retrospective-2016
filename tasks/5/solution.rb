class ArrayStore
  attr_reader :storage

  def initialize
    @storage = []
    @id = 0
  end

  def increment_id
    @id += 1
  end

  def create(record)
    @storage << record
  end

  def find(query)
    @storage.select { |record| matching? query, record }
  end

  def update(id, record)
    index = @storage.find_index { |record| record[:id] == id }
    @storage[index] = record if index
  end

  def delete(query)
    @storage.reject! { |record| matching? query, record }
  end

  private
  def matching?(query, record)
    query.all? { |key, value| record[key] == value }
  end
end

class HashStore
  attr_reader :storage

  def initialize
    @storage = {}
    @id = 0
  end

  def increment_id
    @id += 1
  end

  def create(record)
    @storage[record[:id]] = record
  end

  def find(query)
    @storage.values.select { |record| matching? query, record }
  end

  def delete(query)
    find(query).each { |record| @storage.delete(record[:id]) }
  end

  def update(id, record)
    return unless @storage.key? id
    @storage[id] = record
  end

  private
  def matching?(query, record)
    query.all? { |key, value| record[key] == value }
  end
end

module Model
  def attributes(*attributes)
    return @attributes if attributes.empty?
    @attributes = attributes + [:id]
    @attributes.each do |attribute|
      define_singleton_method "find_by_#{attribute}" do |value|
        where(attribute => value)
      end
      define_method(attribute)       { @attributes[attribute] }
      define_method("#{attribute}=") { |value| @attributes[attribute] = value }
    end
  end

  def data_store(store = nil)
    return @data_store unless store
    @data_store = store
  end

  def where(query)
    query.keys.reject { |key| @attributes.include? key }.each do |key|
      raise DataModel::UnknownAttributeError.new(key)
    end
    data_store.find(query).map { |record| new(record) }
  end
end

class DataModel
  class UnknownAttributeError < ArgumentError
    def initialize(attribute_name)
      super "Unknown attribute #{attribute_name}"
    end
  end

  class DeleteUnsavedRecordError < StandardError
  end

  extend Model
  def initialize(attributes = {})
    @attributes = attributes.select { |key, _| self.class.attributes.include? key }
  end

  def save
    id ? update : create
    self
  end

  def create
    self.id = self.class.data_store.increment_id
    self.class.data_store.create(@attributes)
  end

  def update
    self.class.data_store.update(id, @attributes)
  end

  def delete
    if id
      self.class.data_store.delete(id: id)
    else
      raise DeleteUnsavedRecordError
    end
  end

  def ==(second)
    id && second.id ? (id == second.id) : (self.equal? second)
  end
end
