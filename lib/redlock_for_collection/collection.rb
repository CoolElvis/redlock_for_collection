module RedlockForCollection
  class Collection
    DEFAULT_TTL = 10_000
    DEFAULT_MIN_VALIDITY = 5_000
    DEFAULT_KEY_METHOD = 'key'.freeze
    DEFAULT_KEY_PREFIX = 'prefix'.freeze

    LockPair = Struct.new(:object, :lock_info, :status)

    attr_reader :objects, :options, :pool

    def initialize(objects, options, pool)
      @objects = objects
      @options = options
      @pool    = pool

      init_options
    end

    def lock(&block)
      lock_pairs = []

      start_time = (Time.now.to_f * 1000).to_i
      @objects.each do |object|
        @pool.with do |redlock|
          lock_info = redlock.lock(build_key_for(object), @options[:ttl])
          lock_pairs << LockPair.new(object, lock_info)
        end
      end
      end_time = (Time.now.to_f * 1000).to_i

      separated_pairs = separate_expired_pairs(lock_pairs, end_time - start_time)

      begin
        separated_pairs[:valid].map(&:object)
        separated_pairs[:expired].map(&:object)
        block.yield(separated_pairs[:valid].map(&:object), separated_pairs[:expired].map(&:object))
      ensure
        # Release the all acquired locks
        unlock(lock_pairs)
      end
    end

    protected

    def init_options
      @options[:key_prefix]   ||= DEFAULT_KEY_PREFIX
      @options[:key_method]   ||= DEFAULT_KEY_METHOD
      @options[:min_validity] ||= DEFAULT_MIN_VALIDITY
      @options[:ttl]          ||= DEFAULT_TTL
    end

    # @param lock_pairs [Array<LockPair>]
    def unlock(lock_pairs)
      @pool.with do |redlock|
        lock_pairs.each do |lock_pair|
          redlock.unlock(lock_pair.lock_info) if lock_pair.lock_info
        end
      end
    end

    def build_key_for(object)
      (@options[:key_prefix]) + object.send(@options[:key_method]).to_s
    end

    # @param lock_pairs [Array<LockPair>]
    # @param elapsed [Integer]
    # @return [Hash]
    def separate_expired_pairs(lock_pairs, elapsed)
      expired_pairs = []
      valid_pairs   = []

      lock_pairs.each do |lock_pair|
        if lock_pair.lock_info && ((lock_pair.lock_info[:validity] - elapsed) > (@options[:min_validity]))
          lock_pair.status = :valid
          valid_pairs << lock_pair
        else
          lock_pair.status= :expired
          expired_pairs <<  lock_pair
        end
      end

      { valid: valid_pairs, expired: expired_pairs }
    end

  end
end

