module RedlockForCollection
  class Collection
    DEFAULT_TTL = 10_000
    DEFAULT_MIN_VALIDITY = 5_000
    DEFAULT_KEY_METHOD = 'key'.freeze
    DEFAULT_KEY_PREFIX = 'prefix'.freeze

    attr_reader :objects, :options, :pool

    def initialize(objects, options, pool)
      @objects = objects
      @options = options
      @pool    = pool

      init_options
    end


    def lock(&block)
      locked_objects   = []
      unlocked_objects = []

      locks_info         = []
      expired_locks_info = []

      @objects.each do |object|
        @pool.with do |redlock|
          lock_info = redlock.lock(build_key_for(object), @options[:ttl])

          # Check if ttl is enough
          if lock_info && (lock_info[:validity] > (@options[:min_validity]))
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
        unlock(expired_locks_info)
        unlock(locks_info)
      end
    end


    protected

    def unlock(locks_info)
      @pool.with do |redlock|
        locks_info.each { |lock_info| redlock.unlock(lock_info) }
      end
    end

    def init_options
      @options[:key_prefix]   ||= DEFAULT_KEY_PREFIX
      @options[:key_method]   ||= DEFAULT_KEY_METHOD
      @options[:min_validity] ||= DEFAULT_MIN_VALIDITY
      @options[:ttl]          ||= DEFAULT_TTL
    end

    def build_key_for(object)
      (@options[:key_prefix]) + object.send(@options[:key_method]).to_s
    end

  end
end

