module Transform
  class Application
    def self.run! *args
      require 'trollop'
      $OPTS = Trollop::options(args) do
        opt :no_cache, "don't use previously computed collection", default: false
      end
      $LOAD_PATH.unshift File.new('.')
      require args.first
      return 0
    end
  end
end