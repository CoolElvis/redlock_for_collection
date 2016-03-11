[![Build Status](https://travis-ci.org/CoolElvis/redlock_for_collection.svg?branch=master)](https://travis-ci.org/CoolElvis/redlock_for_collection)
[![Code Climate](https://codeclimate.com/github/CoolElvis/redlock_for_collection/badges/gpa.svg)](https://codeclimate.com/github/CoolElvis/redlock_for_collection)
[![Test Coverage](https://codeclimate.com/github/CoolElvis/redlock_for_collection/badges/coverage.svg)](https://codeclimate.com/github/CoolElvis/redlock_for_collection/coverage)
[![Issue Count](https://codeclimate.com/github/CoolElvis/redlock_for_collection/badges/issue_count.svg)](https://codeclimate.com/github/CoolElvis/redlock_for_collection)
# RedlockForCollection

This is just a [Redlock](http://redis.io/topics/distlock) wrapper for collection of objects. 

Also it used a connection pool for restrict the redis connections. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'redlock_for_collection'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redlock_for_collection

## Usage

```ruby
collection_manager = RedlockForCollection::Manager.new
options = { key_method: :to_s, key_prefix: 'pref', ttl: 20_000, min_validity: 10_00}

collection_manager.with_lock(objects, options: options) do |locked_objects, unlocked_objects|
    ... do some things with locked_objects
    ... do some things with unlocked_objects
end
```
#### options
+ `:ttl` time to live of lock.
+ `:key_method` invoked on `object` of `objects_collection` to generate shared key.
+ `:key_prefix` prepended to the shared key 
+ if lock validity < `:min_validity` then lock is treated as expired 
+ `locked_objects` is successfully locked objects of collections
+ `unlocked_objects` is unsuccessfully locked objects of collections for any reasons

### Configuration 
 
```ruby
collection_manager = RedlockForCollection::Manager.new

collection_manager.configure do |configuration|
   config.pool_size = 2
   config.redis_urls = ['redis://localhost:6379']
   config.retry_delay = 2
   config.retry_count = 2
end
```

Also you can provide a pool 
  
```ruby  
manager = RedlockForCollection::Manager.new
redlock_pool = ConnectionPool.new { Redlock::Client.new([redis_urls]) }

manager.configure do |configuration|
  config.pool = redlock_pool
end
```
 
## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CoolElvis/redlock_for_collection.
