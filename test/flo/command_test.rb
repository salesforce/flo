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
