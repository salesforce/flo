require_relative '../minitest_helper'
require 'flo/command'
require 'ostruct'

module Flo
  class CommandTest < Flo::UnitTest

    MockResponse = Struct.new(:success?)
    SUCCESS_RESPONSE = MockResponse.new(true)
    FAILURE_RESPONSE = MockResponse.new(false)
    ProviderMock = Class.new

    def subject
      @subject_arguments ||= [:foo]
      @subject_block ||= lambda { }
      @subject ||= Flo::Command.new(
        @subject_arguments,
        performer_class: performer_class_mock,
        &@subject_block
        )
    end

    def performer_class_mock
      @performer_class_mock ||= Minitest::Mock.new
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
      performer_obj = Object.new
      performer_class_mock.expect(:new, performer_obj, [Symbol, :validate_example_method, Hash])

      subject.validate :provider_sym, :example_method, {}

      assert_includes subject.tasks, performer_obj

      performer_class_mock.verify
    end

    def test_validate_forwards_any_number_of_arguments
      performer_class_mock.expect(:new, :return_value, [Symbol, Symbol, {options: :hash}])

      subject.validate :class, :method, {options: :hash}

      performer_class_mock.verify
    end

    def test_perform_registers_a_performer
      performer_obj = Object.new
      performer_class_mock.expect(:new, performer_obj, [Symbol, :example_method, Hash])

      subject.perform :provider_sym, :example_method, {}

      assert_includes subject.tasks, performer_obj

      performer_class_mock.verify
    end

    def test_execute_calls_execute_on_tasks_and_returns_status
      performer_obj = Minitest::Mock.new
      providers_hash = Object.new
      performer_obj.expect(:execute, SUCCESS_RESPONSE, [providers_hash, []])
      performer_class_mock.expect(:new, performer_obj, [:provider, :perform_success, {}])

      @subject_block = lambda do
        perform :provider, :perform_success
      end

      assert subject.execute(providers_hash).success?

      [
        performer_obj,
        performer_class_mock
      ].each(&:verify)
    end

    def test_execute_stops_and_returns_failure_if_task_is_not_successful
      providers_hash = Object.new

      validation_obj = Minitest::Mock.new
      validation_obj.expect(:execute, FAILURE_RESPONSE, [providers_hash, []])
      performer_class_mock.expect(:new, validation_obj, [:provider, :validate_validation_fails, {}])

      performer_obj = Minitest::Mock.new
      performer_class_mock.expect(:new, performer_obj, [:provider, :not_called, {}])

      @subject_block = lambda do
        validate :provider, :validation_fails
        perform :provider, :not_called
      end

      refute subject.execute(providers_hash).success?

      [
        validation_obj,
        performer_obj
      ].each(&:verify)
    end

    def test_execute_raises_if_required_args_not_passed
      @subject_block = lambda { |required_argument| }

      # Show that the method call is correct and doesn't raise when arguments are passed
      subject.execute({}, :foo)

      assert_raises(ArgumentError) do
        subject.execute({})
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

