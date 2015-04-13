require_relative '../minitest_helper'
require 'flo/command'
require 'ostruct'

module Flo
  class CommandTest < Flo::UnitTest

    MockResponse = Struct.new(:success?)
    SUCCESS_RESPONSE = MockResponse.new(true)
    FAILURE_RESPONSE = MockResponse.new(false)

    def subject
      @subject_arguments ||= [:foo]
      @subject_block ||= lambda { }
      @subject ||= Flo::Command.new(
        @subject_arguments,
        performer_class: performer_class_mock,
        providers: {},
        &@subject_block
      )
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

    def test_tasks_is_an_array
      assert_kind_of Array, subject.tasks
    end

    def test_validate_registers_a_validation_with_transformed_method
      @performer_class_mock = Minitest::Mock.new
      performer_class_mock.expect(:new, performer_obj, [Symbol, :validate_example_method, {}, Hash])

      subject.validate :provider_sym, :example_method, {}

      assert_includes subject.tasks, performer_obj

      performer_class_mock.verify
    end

    def test_validate_forwards_any_number_of_arguments
      @performer_class_mock = Minitest::Mock.new
      performer_class_mock.expect(:new, :return_value, [Symbol, Symbol, {}, {options: :hash}])

      subject.validate :class, :method, {options: :hash}

      performer_class_mock.verify
    end

    def test_perform_registers_a_performer
      subject.perform :provider_sym, :example_method, {}

      assert_includes subject.tasks, performer_obj

      performer_class_mock.verify
    end

    def test_call_calls_call_on_tasks_and_returns_status
      @performer_obj = lambda { SUCCESS_RESPONSE }

      @subject_block = lambda do
        perform :provider, :perform_success
      end

      assert subject.call.success?

      performer_class_mock.verify
    end

    def test_call_stops_and_returns_failure_if_task_is_not_successful
      @performer_class_mock = Minitest::Mock.new
      validation_obj = lambda { |args=[]| FAILURE_RESPONSE }
      performer_class_mock.expect(:new, validation_obj, [:provider, :validate_validation_fails, {}, {}])

      performer_obj = lambda { |args=[]| raise "should not pass validation" }
      performer_class_mock.expect(:new, performer_obj, [:provider, :not_called, {}, {}])

      @subject_block = lambda do
        validate :provider, :validation_fails
        perform :provider, :not_called
      end

      refute subject.call.success?
    end

    def test_call_raises_if_required_args_not_passed
      @subject_block = lambda { |required_argument| }

      # Show that the method call is correct and doesn't raise when arguments are passed
      subject.call(:foo)

      assert_raises(ArgumentError) do
        subject.call
      end
    end

    class MockValidation
      attr_reader :args
      def initialize(*args)
        @args = args
      end
    end
  end
end

