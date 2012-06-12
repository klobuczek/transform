module Transform
  class Graph
    attr_accessor :nodes

    def initialize
      @nodes = []
    end

    def add collection, dependencies, options={}, &block
      nodes << Transform::Node.new(collection, [dependencies].flatten, options, &block)
    end

    def execution_path collection
      node = nodes.detect {|node| node.name == collection}
      node.dependencies.inject([node]) {|nodes, node_name| execution_path(node_name) + nodes}.uniq
    end

    def execute collection
      execution_path(collection).each {|node| node.execute}
    end
  end
end