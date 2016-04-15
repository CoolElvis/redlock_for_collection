require_relative 'test_helper'

class RedlockForCollectionTest < MiniTest::Test
  def setup

  end

  def test_main
    manager = RedlockForCollection::Manager.new do |config|
      config.retry_delay = 0
      config.retry_count = 1
    end

    options = {key_prefix: SecureRandom.base64(4), key_method: :to_s, ttl: 10_000 }
    order_ids = (1..100).to_a

    Thread.new do
      manager.with_lock(order_ids, options: options) do |locked_objects, unlocked_objects|
        assert_equal(100, locked_objects.count)
        assert_equal(0, unlocked_objects.count)
        sleep 5
      end
    end

    sleep 1.1

    manager.with_lock(order_ids, options: options) do |locked_objects, unlocked_objects|
      assert_equal(0, locked_objects.count)
      assert_equal(100, unlocked_objects.count)
    end


  end


  def test_only_one_slow
    require 'securerandom'

    manager = RedlockForCollection::Manager.new do |config|
      config.retry_delay = 2000
      config.retry_count = 2
    end

    options = { key_prefix: SecureRandom.base64(4),  key_method: :to_s, ttl: 40_000, min_validity: 38_900 }

    order_ids = (1..100).to_a

    Thread.new do
      manager.with_lock([order_ids.first], options: options) do |locked_objects, unlocked_objects|
        assert_equal(1, locked_objects.count)
        assert_equal(0, unlocked_objects.count)
        sleep 50
      end
    end

    sleep 0.1

    manager.with_lock(order_ids, options: options) do |locked_objects, unlocked_objects|
      assert_equal(0, locked_objects.count)
      assert_equal(100, unlocked_objects.count)
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

