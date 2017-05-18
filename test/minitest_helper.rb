# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require 'simplecov'
SimpleCov.start

SimpleCov.configure do
  add_filter "/test/"
end

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
