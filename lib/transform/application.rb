module Transform
  class Application
    def self.run! *args
      puts "OK! 1"
      require "transform/script"
      puts Transform::Dsl.graph.inspect
      #Transform::Dsl.graph.execute
      return 0
    end
  end
end