require 'csv'

module Transform
  class Node
    attr_accessor :name, :dependencies, :file, :fields, :options, :block, :data

    def initialize(name, dependencies, options, &block)
      self.name = name
      self.dependencies = dependencies
      self.file = options.delete(:file)
      self.fields = options.delete(:fields)
      self.options = options
      self.block = block
    end

    def execute
      send options[:operation], &block unless file
    end

    def define_collection
      self.file = "#{name}.csv"
    end

    def calculate
      self.data = []
      dependencies.first.with_data do |rows|
        rows.each do |row|
          data << Row.new([block.call(row)], fields)
        end
      end
      save
    end

    def compose
      self.fields = dependencies.first.fields + dependencies.last.fields
      self.data = []
      dependencies.last.load
      dependencies.first.with_data do |rows1|
        rows1.each_with_index do |row1, index1|
          dependencies.last.data.each_with_index do |row2, index2|
            data << Row.new(row1.raw + row2.raw, fields) if (block.nil? ? index1 == index2 : block.call(row1, row2))
          end
        end
      end
      dependencies.last.unload
      save
    end

    def slice
      self.data = []
      dependencies.first.with_data do |rows|
        rows.each do |row|
          new_row = []
          fields.each { |field| new_row << row.send(field) }
          data << Row.new(new_row, fields)
        end
      end
      save
    end

    def filter
      self.fields = dependencies.first.fields
      self.data = []
      dependencies.first.with_data do |rows|
        rows.each do |row|
          data << row if block.call(row)
        end
      end
      save
    end

    def aggregate
      self.data = []
      aggregate_value = nil
      dependencies.first.with_data do |rows|
        aggregate_value = rows.inject(options[:initial_value]) do |agg, row|
          block.call(agg, row)
        end
      end
      self.data = [Row.new([aggregate_value], fields)]
      save
    end

    def load
      self.data = []
      CSV.foreach(file) { |row| data << Transform::Row.new(row, fields) }
    end

    def unload
      self.data = nil
    end

    def save
      load unless data
      self.file = "#{name}.csv" unless file
      File.open(file, 'w') do |f|
        data.each do |row|
          f.puts row.to_s
        end
      end
      unload
    end

    def with_data
      load
      yield data
      save unless file
      unload
    end
  end
end