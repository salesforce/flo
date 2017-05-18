# Copyright (c) 2017, Salesforce.com, Inc.
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
