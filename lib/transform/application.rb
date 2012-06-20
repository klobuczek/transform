module Transform
  class Application
    def self.run! *args
      $LOAD_PATH.unshift File.new('.')
      require args.first
      return 0
    end
  end
end