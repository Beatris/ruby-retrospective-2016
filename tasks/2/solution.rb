class Hash
  def fetch_deep(path)
    head, tail = *path.strip.reverse.chomp('.').reverse.chomp('.').split('.', 2)
    value = [dig(head), dig(head.to_sym)].find(&:itself)
    return value unless tail
    if value.is_a?(Hash)
      value.fetch_deep(tail)
    elsif value.is_a?(Array)
      Hash[(0..(value.size - 1)).map { |x| x.to_s }.zip(value)].fetch_deep(tail)
    end
  end

  def reshape(structure)
    result = structure.clone
    result.each do |key, value|
      result[key] = value.is_a?(Hash) ? self.reshape(value) : fetch_deep(value)
    end
  end
end

class Array
  def reshape(structure)
    each_with_index { |val, index| self[index] = val.reshape(structure) }
  end
end
