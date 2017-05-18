# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require_relative '../minitest_helper'
require 'flo/config'

module Flo
  class ConfigTest < Flo::UnitTest

    def subject
      @subject ||= Flo::Config.new
    end

    def test_provider_instantiates_new_provider
      assert_equal({}, subject.providers)
      subject.provider(:mock_provider)
      assert_kind_of Flo::Provider::MockProvider, subject.providers[:mock_provider]
    end

    def test_raises_helpful_error_if_provider_not_required
      assert_raises(Flo::MissingRequireError) do
        subject.provider :doesnt_exist
      end
    end

  end
  module Provider
    class MockProvider
      def initialize(args={})
      end
    end
  end
end
