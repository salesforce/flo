# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require_relative '../minitest_helper'
require 'flo/command'
require 'ostruct'

module Flo
  class CommandTest < Flo::UnitTest

    def subject
      @subject_block ||= lambda { }
      @providers ||= { mocked_provider: mock }
      @state_class_mock ||= Object
      @subject ||= Flo::Command.new(
        providers: @providers,
        state_class: @state_class_mock,
        task_class: MockTask,
        &@subject_block
      )
    end

    def mock
      @mock ||= MockProvider.new
    end

    def performer_class_mock
      @performer_class_mock ||= begin
        mock = Minitest::Mock.new
        mock.expect(:new, performer_obj, [Symbol, Symbol, {}, Hash])
      end
    end

    def performer_obj
      @performer_obj ||= lambda { }
    end

    def test_new_raises_if_no_block_provided
      assert_raises(ArgumentError) do
        Flo::Command.new(:foo)
      end
    end

    def test_task_called_with_args
      @subject_block = lambda do |*args|
        perform :mocked_provider, :provider_method, baz: 2
      end

      result = subject.call(bar: 1)

      assert_equal([{ bar: 1 }], result.args_passed)
      assert_equal({ baz: 2 }, result.args_initialized.last)
    end

    def test_call_stops_and_returns_failure_early_if_task_is_not_successful
      @subject_block = lambda do |*args|
        perform :mocked_provider, :failed_provider_method, {success: false}
        perform :mocked_provider, :provider_method, {fail: true}
      end

      refute subject.call.success?
    end

    def test_state_is_not_invoked_during_configuration_phase
      @state_class_mock = Minitest::Mock.new
      state_mock = Minitest::Mock.new
      @state_class_mock.expect(:new, state_mock, [mock])

      state_mock.expect(:state_method, lambda { raise "This should never be evaluated" }, [] )
      subject.perform :mocked_provider, :provider_method, {evaluated_later: subject.state(:mocked_provider).state_method }
    end

    class MockProvider
      attr_reader :args, :state_method_called

      def state_method
        @state_method_called = true
      end
    end

    class MockTask
      def initialize(*args)
        @initial_args = args
      end

      def call(*args)
        fail("This task should never have been called") if @initial_args.last.fetch(:fail, false)
        success = @initial_args.last.fetch(:success, true)
        OpenStruct.new(success?: success, args_passed: args, args_initialized: @initial_args)
      end
    end
  end
end
