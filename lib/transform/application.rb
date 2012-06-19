module Transform
  class Application
    def self.run! *args
      require "transform/script"
      Transform::Dsl.graph.store :a
      return 0
    end
  end
end