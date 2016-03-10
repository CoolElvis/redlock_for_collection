require 'connection_pool'
require 'redlock'

module RedlockForCollection
  class Configuration
    attr_accessor :pool_size,
                  :pool_timeout,
                  :redis_urls,
                  :retry_delay,
                  :retry_count,
                  :pool

    def initialize
      @pool_size    = 5
      @pool_timeout = 5
      @redis_urls   = ['redis://localhost:6379']
      @retry_delay  = 5
      @retry_count  = 5
      @pool         = nil
    end


    def pool
      @pool|| begin
        @pool = ConnectionPool.new(size: @pool_size, timeout: @pool_timeout) do
          Redlock::Client.new(@redis_urls, retry_delay: @retry_delay, retry_count: @retry_count)
        end
      end
    end

  end
end

