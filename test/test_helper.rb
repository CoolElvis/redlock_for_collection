require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'minitest/autorun'
require 'minitest/pride'
require 'redlock_for_collection'
require 'securerandom'

Thread.abort_on_exception=true
