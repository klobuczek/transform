module Transform
  class Row
    def initialize raw, *fields
      @raw = raw
      @fields = fields
    end

    def method_missing(method, *args, &block)
      index = @fields.index method
      index and raw[index] or super
    end

    def to_s
      raw.join(',')
    end
  end
end

