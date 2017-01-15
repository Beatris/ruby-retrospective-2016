class Hash
  def fetch_deep(path)
    head, tail = path.split('.', 2)
    value = self[head.to_s] || self[head.to_sym]
    return value unless tail
    value.fetch_deep(tail) if value
  end

  def reshape(structure)
    return fetch_deep(structure) if structure.is_a? String
    structure.map do |key, value|
      [key, self.reshape(value)]
    end.to_h
  end
end

class Array
  def reshape(structure)
    map { |val| val.reshape(structure) }
  end

  def fetch_deep(path)
    head, tail = path.split('.', 2)
    element = self[head.to_i]
    element.fetch_deep(tail) if element
  end
end
