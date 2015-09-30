# Copyright (c) 2015, Salesforce.com, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# * Neither the name of Salesforce.com nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

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

    def test_state_is_not_invoked_during_configuration_phase
      @state_class_mock = Minitest::Mock.new
      state_mock = Minitest::Mock.new
      @state_class_mock.expect(:new, state_mock, [mock])

      state_mock.expect(:state_method, lambda { raise "This should never be evaluated" }, [] )
      subject.perform :mocked_provider, :provider_method, {evaluated_later: subject.state(:mocked_provider).state_method }
    end

    def test_state_is_invoked_during_call_phase
      lambda_invoked = false

      @state_class_mock = Minitest::Mock.new
      state_mock = Minitest::Mock.new
      @state_class_mock.expect(:new, state_mock, [mock])

      state_mock.expect(:state_method, lambda { lambda_invoked = true; :return_value }, [] )

      @subject_block = lambda do |*args|
        perform :mocked_provider, :provider_method, {evaluated_later: state(:mocked_provider).state_method }
      end

      subject.call

      assert_equal({evaluated_later: :return_value}, mock.args)
      assert lambda_invoked, "Provider method was never invoked"
    end

    class MockProvider
      attr_reader :args, :provider_method_called, :failed_provider_method_called, :state_method_called

      def provider_method(args={})
        @args = args
        @provider_method_called = true
        OpenStruct.new(success: true)
      end

      def failed_provider_method(args={})
        @failed_provider_method_called = true
        OpenStruct.new(success: false)
      end

      def state_method
        @state_method_called = true
      end
    end

  end
end

