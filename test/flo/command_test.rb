require_relative '../minitest_helper'
require 'flo/command'
require 'ostruct'

module Flo
  class CommandTest < Flo::UnitTest

    def subject
      @subject_block ||= lambda { }
      @providers ||= { mocked_provider: mock }
      @subject ||= Flo::Command.new(
        providers: @providers,
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

    def test_call_calls_method_on_provider
      @subject_block = lambda do |*args|
        perform :mocked_provider, :provider_method
      end

      subject.call

      assert mock.provider_method_called
    end

    def test_validate_calls_method_on_provider
      @subject_block = lambda do |*args|
        validate :mocked_provider, :provider_method
      end

      subject.call

      assert mock.provider_method_called
    end

    def test_call_merges_command_options_with_task_options
      @subject_block = lambda do |*args|
        perform :mocked_provider, :provider_method, { task_option: :b }
      end

      subject.call(command_option: :a)

      assert_equal({command_option: :a, task_option: :b}, mock.args)
    end

    def test_call_stops_and_returns_failure_early_if_task_is_not_successful
      @subject_block = lambda do |*args|
        perform :mocked_provider, :failed_provider_method
        perform :mocked_provider, :provider_method
      end

      refute subject.call.success?

      assert mock.failed_provider_method_called
      refute mock.provider_method_called
    end

    class MockProvider
      attr_reader :args, :provider_method_called, :failed_provider_method_called

      def initialize()
        @provider_method_called = false
        @failed_provider_method_called = false
      end

      def provider_method(args={})
        @args = args
        @provider_method_called = true
        OpenStruct.new(success: true)
      end

      def failed_provider_method(args={})
        @failed_provider_method_called = true
        OpenStruct.new(success: false)
      end
    end

  end
end

