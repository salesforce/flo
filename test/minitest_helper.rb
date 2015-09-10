$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
TEST_ROOT = File.dirname(__FILE__)
FIXTURES_ROOT = File.expand_path('../fixtures', __FILE__)
ENV["MT_NO_SKIP_MSG"] = "true"

require 'minitest/autorun'
require 'pry'

module Flo
  class UnitTest < Minitest::Test
    self.parallelize_me!
  end
end
