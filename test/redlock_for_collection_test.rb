require_relative 'test_helper'


class RedlockForCollectionTest < MiniTest::Test
  def setup
    @order_ids = (1..100).to_a
  end

  def test_main
    manager = RedlockForCollection::Manager.new

    options = { key_method: :to_s, ttl: 20_000 }

    Thread.new do
      manager.lock_collection(@order_ids, options: options) do |locked_objects, unlocked_objects|
        assert_equal(locked_objects.count, 100)
        assert_equal(unlocked_objects.count, 0)
        sleep 5
      end
    end

    sleep 0.1

    manager.lock_collection(@order_ids, options: options) do |locked_objects, unlocked_objects|
      assert_equal(locked_objects.count, 0)
      assert_equal(unlocked_objects.count, 100)
    end

  end


end

