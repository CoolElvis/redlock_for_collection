module RedlockForCollection
  class Collection
    DEFAULT_TTL = 10_000
    DEFAULT_MIN_VALIDITY = 5_000
    DEFAULT_KEY_METHOD = 'key'.freeze
    DEFAULT_KEY_PREFIX = 'prefix'.freeze

    attr_reader :objects, :options, :redlock_pool

    def initialize(objects, options, redlock_pool)
      @objects = objects
      @options = options
      @redlock_pool = redlock_pool

      set_default_options
    end

    def set_default_options
      @options[:key_prefix]   ||= DEFAULT_KEY_PREFIX
      @options[:key_method]   ||= DEFAULT_KEY_METHOD
      @options[:min_validity] ||= DEFAULT_MIN_VALIDITY
      @options[:ttl]          ||= DEFAULT_TTL
    end

    def lock(&block)
      locked_objects = []

      start_time = time_now
      @objects.each do |object|
        locked_object = LockedObject.new(object, @options , @redlock_pool)
        locked_object.lock

        locked_objects << locked_object
      end
      end_time = time_now

      separated_expired_objects = separate_expired_objects(locked_objects, end_time - start_time)

      begin
        block.yield(separated_expired_objects[:valid].map(&:object), separated_expired_objects[:expired].map(&:object))
      ensure
        locked_objects.each { |locked_object| locked_object.unlock }
      end
    end

    protected

    def time_now
      (Time.now.to_f * 1000).to_i
    end

    # @param locked_objects [Array<LockedObject>]
    # @param elapsed [Integer]
    # @return [Hash]
    def separate_expired_objects(locked_objects, elapsed)
      expired_locked_objects = []
      valid_locked_objects   = []

      locked_objects.each do |locked_object|
        if locked_object.valid?(elapsed)
         valid_locked_objects << locked_object
        else
          expired_locked_objects << locked_object
        end
      end

      { valid: valid_locked_objects, expired: expired_locked_objects }
    end

  end
end

