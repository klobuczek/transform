module Transform
  class Table
    attr_accessor :file, :fields, :rows

    def initialize file, *fields
      self.file=file
      self.fields=fields
      load_csv
    end

    def foreach
      FasterCSV.foreach {|row| yield Transform::Row.new(row, fields)}
    end

    def to_s
      data = fields.join(',')
      foreach {|row| data << row.to_s}
      data.join('\n')
    end
  end
end