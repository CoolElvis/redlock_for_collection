require_relative 'redlock_for_collection/version'
require_relative 'redlock_for_collection/configuration'

module RedlockForCollection
  class Manager

    DEFAULT_TTL = 10_000
    DEFAULT_MIN_VALIDITY = 5_000
    DEFAULT_KEY_METHOD = 'key'.freeze
    DEFAULT_KEY_PREFIX = 'prefix'.freeze

    attr_reader :configuration


    def initialize
      @configuration = Configuration.new

      yield @configuration if block_given?
    end


    def configure(&block)
      yield @configuration
    end


    def lock_collection(collection, options:{}, &block)

      locked_objects   = []
      unlocked_objects = []

      locks_info         = []
      expired_locks_info = []

      collection.flatten.map(&:to_s).uniq .each do |object|

        key = (options[:key_prefix] || DEFAULT_KEY_PREFIX) + object.send(options[:key_method] || DEFAULT_KEY_METHOD).to_s

        @configuration.pool.with do |lock_manager|
          lock_info = lock_manager.lock(key, options[:ttl] || DEFAULT_TTL)

          # Check if ttl is enough
          if lock_info && (lock_info[:validity] > (options[:min_validity] || DEFAULT_MIN_VALIDITY))
            locked_objects << object
            locks_info     << lock_info
          else
            expired_locks_info << lock_info if lock_info
            unlocked_objects   << object
          end
        end

      end

      begin
        block.yield(locked_objects, unlocked_objects)
      ensure

        # Release the all acquired locks
        @configuration.pool.with do |lock_manager|
          # TODO do it concurrently
          expired_locks_info.each { |expired_lock_info| lock_manager.unlock(expired_lock_info) }

          locks_info.each { |lock_info| lock_manager.unlock(lock_info) }
        end

      end

    end
  end
end

