module RedlockForCollection
  class LockedObject
    attr_reader :object,
                :lock_info,
                :status,
                :redlock_pool,
                :key

    def initialize(object, options, redlock_pool)
      @object       = object
      @options      = options
      @redlock_pool = redlock_pool
      build_key
    end

    def lock
      @redlock_pool.with do |redlock|
        @lock_info = redlock.lock(@key, @options[:ttl])
      end
    end

    def unlock
      if @lock_info
        @redlock_pool.with do |redlock|
          redlock.unlock(@lock_info)
        end
      end
    end

    def expired?(elapsed_time)
      !valid?(elapsed_time)
    end

    def valid?(elapsed_time)
       @lock_info && ((@lock_info[:validity] - elapsed_time) > (@options[:min_validity]))
    end

    private

    def build_key
      @key = (@options[:key_prefix]) + @object.send(@options[:key_method]).to_s
    end

  end
end
