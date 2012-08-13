require 'csv'

module Transform
  class Node
    attr_accessor :name, :dependencies, :file, :fields, :options, :block, :data

    def initialize(name, dependencies, options, &block)
      self.name = name
      self.dependencies = dependencies
      self.file = "#{name}.csv"
      self.options = options
      self.block = block
      assign_fields
    end

    def assign_fields
      self.fields =
          case options[:operation]
            when :project
              dependencies.first.fields + except(options, :operation).keys
            when :compose
              dependencies.first.fields + dependencies.last.fields
            when :filter
              dependencies.first.fields
            else
              options.delete(:fields)
          end
    end

    def except(hash, key)
      hash.dup.tap { |h| h.delete key }
    end

    def execute
      create_data do
        send options.delete(:operation), &block
      end unless cached? || options[:operation] == :define_collection
    end

    def cached?
      !$OPTS[:no_cache] && File.exist?(file)
    end

    def calculate
      dependencies.first.with_data do |rows|
        rows.each do |row|
          data << Row.new([block.call(row)], fields)
        end
      end
    end

    def compose
      dependencies.last.load
      dependencies.first.with_data do |rows1|
        rows1.each_with_index do |row1, index1|
          dependencies.last.data.each_with_index do |row2, index2|
            data << Row.new(row1.raw + row2.raw, fields) if (block.nil? ? index1 == index2 : block.call(row1, row2))
          end
        end
      end
      dependencies.last.unload
    end

    def slice
      dependencies.first.with_data do |rows|
        rows.each do |row|
          new_row = []
          fields.each { |field| new_row << row.send(field) }
          data << Row.new(new_row, fields)
        end
      end
    end

    def filter
      dependencies.first.with_data do |rows|
        rows.each do |row|
          data << row if block.call(row)
        end
      end
    end

    def aggregate
      aggregate_value = nil
      dependencies.first.with_data do |rows|
        aggregate_value = rows.inject(options[:initial_value], &block)
      end
      self.data = [Row.new([aggregate_value], fields)]
    end

    def group
      groups = {}
      initial_values = options[:computations].keys.map { |key| [0, options[:computations][key]] }
      dependencies.first.with_data do |rows|
        rows.each do |row|
          ids = fields.map { |field| row.send field }
          groups[ids] ||= initial_values
          groups[ids] = group[ids].map do |agg, block|
            block.call(agg, row)
          end
        end
      end
      self.data = groups.map do |key, value|
        Row.new(key + value.map { |agg, block| agg }, fields + options[:computations].keys)
      end
    end

    def project
      dependencies.first.with_data do |rows|
        previous = nil
        rows.each do |row|
          def row.previous
            previous
          end

          data << Row.new(options.values.inject(row) { |row, block| row.add block.call(row) }.raw, fields)
          previous = data.last
        end
      end
    end

    def generate
      self.data=
          (0..(options[:count]-1)).to_a.map do |index|
            Row.new([block.call(index)], fields)
          end
    end

    def load
      self.data = []
      CSV.foreach(file) { |row| data << Transform::Row.new(row, fields) }
    end

    def unload
      self.data = nil
    end

    def with_data
      load
      yield data
      unload
    end

    def save
      File.open(file, 'w') do |f|
        data.each do |row|
          f.puts row.to_s
        end
      end
    end

    def create_data
      self.data = []
      yield
      save
      unload
    end
  end
end
