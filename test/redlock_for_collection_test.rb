require_relative 'test_helper'


class RedlockForCollectionTest < MiniTest::Test
  def setup
    @order_ids = (1..100).to_a
  end

  def test_main
    manager = RedlockForCollection::Manager.new

    options = { key_method: :to_s, ttl: 20_000 }

    Thread.new do
      manager.with_lock(@order_ids, options: options) do |locked_objects, unlocked_objects|
        assert_equal(locked_objects.count, 100)
        assert_equal(unlocked_objects.count, 0)
        sleep 5
      end
    end

    sleep 0.1

    manager.with_lock(@order_ids, options: options) do |locked_objects, unlocked_objects|
      assert_equal(locked_objects.count, 0)
      assert_equal(unlocked_objects.count, 100)
    end

  end

  def test_configuration
    manager = RedlockForCollection::Manager.new

    manager.configure do |config|
      config.pool_size = 2
      config.redis_urls = ['redis://localhost:6379']
      config.retry_delay = 2
      config.retry_count = 2
    end

    assert_equal(manager.configuration.pool_size, 2)
    assert_equal(manager.configuration.redis_urls, ['redis://localhost:6379'])
    assert_equal(manager.configuration.retry_delay, 2)
    assert_equal(manager.configuration.retry_count, 2)
  end

end

