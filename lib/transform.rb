require "transform/version"
#require "transform/application"

module Transform
  puts "In transform"
  autoload :Application, 'transform/application'
  autoload :Graph, 'transform/graph'
  autoload :Dsl, 'transform/dsl'
  autoload :Node, 'transform/node'
end
