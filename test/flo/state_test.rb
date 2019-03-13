# Copyright © 2019, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require_relative '../minitest_helper'
require 'flo/state'

module Flo
  class StateTest < Flo::UnitTest

    def subject
      @mock_provider ||= MockProvider.new
      @subject ||= Flo::State.new(@mock_provider)
    end

    def test_meth_missing_returns_lambda
      assert_kind_of Proc, subject.existing_method
    end

    def test_arguments_are_passed_into_returned_lambda
      subject.existing_method(:method_arguments).call

      assert_equal([:method_arguments], @mock_provider.args)
    end

    def test_provider_method_is_called_when_lambda_is_invoked
      subject.existing_method.call

      assert @mock_provider.existing_method_called
    end

    class MockProvider
      attr_reader :args, :existing_method_called
      def existing_method(*args)
        @existing_method_called = true
        @args = args
      end
    end
  end
end
