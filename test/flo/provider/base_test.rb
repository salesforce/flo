# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require_relative '../../minitest_helper'
require 'flo/provider/base'

module Flo
  module Provider
    class BaseTest < Flo::UnitTest

      def subject
        @subject ||= begin
          klass = Class.new(Flo::Provider::Base)
          klass.class_eval do
            def fetch_option(name)
              options.fetch name
            end
          end
          klass
        end
      end

      def test_option_adds_configuration_to_class
        subject.class_eval { option :some_option }

        instance = subject.new(some_option: :foo)

        assert_equal :foo, instance.fetch_option(:some_option)
      end

      def test_option_allows_for_a_default_value
        subject.class_eval { option :default_option, :default_value }

        instance = subject.new

        assert_equal :default_value, instance.fetch_option(:default_option)
      end

      def test_required_options_raise_when_option_not_provided
        subject.class_eval { option :required_option, nil, required: true }

        assert_raises(Flo::Provider::MissingOptionError) do
          subject.new
        end
      end

    end
  end
end
