module Transform
  class Graph
    attr_accessor :nodes

    def initialize
      @nodes = []
    end

    def add collection, dependencies, options={}, &block
      nodes << Transform::Node.new(collection, [dependencies].flatten.map{|name| find(name)}, options, &block)
    end

    def execution_path collection
      node = find(collection)
      node.dependencies.inject([node]) { |nodes, node| execution_path(node.name) + nodes }.uniq
    end

    def find(collection)
      nodes.detect { |node| node.name == collection }
    end

    def execute collection
      execution_path(collection).each { |node| node.execute }
    end

    def store collection
      execute collection
    end
  end
end