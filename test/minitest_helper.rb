$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
TEST_ROOT = File.dirname(__FILE__)

require 'minitest/autorun'
require 'pry'

module Flo
  class UnitTest < Minitest::Test

  end
end
