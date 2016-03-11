require_relative 'redlock_for_collection/version'
require_relative 'redlock_for_collection/configuration'
require_relative 'redlock_for_collection/collection'

module RedlockForCollection
  class Manager
    attr_reader :configuration

    def initialize
      @configuration = Configuration.new

      yield @configuration if block_given?
    end

    # @yields [Configuration]
    def configure(&block)
      block.yield @configuration
    end


    def with_lock(objects_collection, options: {}, &block)
      collection = Collection.new(objects_collection, options, @configuration.pool)

      collection.lock(&block)
    end


  end
end

