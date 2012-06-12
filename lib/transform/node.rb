module Transform
  class Node
    attr_accessor :name, :dependencies, :options, :block, :data

    def initialize(name, dependencies, options, &block)
      self.name = name
      self.dependencies = dependencies
      self.options = options
      self.block = block
    end

    def execute
      send options.delete(:operation)
    end

    def load_collection
      self.data=Transform::Table.new options[:file], options[:fields]
    end
  end
end