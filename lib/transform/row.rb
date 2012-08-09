module Transform
  class Row
    attr_accessor :raw, :fields

    def initialize raw, fields
      self.raw = raw
      self.fields = fields
    end

    def method_missing(method, *args, &block)
      index = fields.index method
      index and raw[index] or super
    end

    def add value
      self.raw = raw + [value]
      self
    end

    def to_s
      raw.join(',')
    end
  end
end

