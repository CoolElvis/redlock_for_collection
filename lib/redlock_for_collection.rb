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

    # @example
    #  configure do |configuration|
    #      config.pool_size = 2
    #      config.redis_urls = ['redis://localhost:6379']
    #      config.retry_delay = 2
    #      config.retry_count = 2
    #  end
    #
    # redlock_pool = ConnectionPool.new { Redlock::Client.new([redis_urls]) }
    #
    # configure do |configuration|
    #   config.pool = redlock_pool
    # end
    #
    # @yield [Configuration]
    def configure(&block)
      block.yield @configuration
    end


    # @param objects_collection [#each]
    # @param options [Hash], consist of `:key_prefix`, `:key_method`, `:min_validity`, `:ttl`
    # `:key_method` invoked on `object` of `objects_collection` to generate shared key.
    # `:key_prefix` prepended to the shared key
    # if lock validity < `:min_validity` then lock is treated as expired
    # @yield [locked_objects, unlocked_objects]
    # `locked_objects` is successfully locked objects of collections
    # `unlocked_objects` is unsuccessfully locked objects of collections for any reasons
    def with_lock(objects_collection, options: {}, &block)
      collection = Collection.new(objects_collection, options, @configuration.pool)

      collection.lock(&block)
    end
  end
end

