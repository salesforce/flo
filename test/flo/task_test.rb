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
require 'flo/task'
require 'ostruct'

module Flo
  class TaskTest < Flo::UnitTest
    def subject
      @method_sym ||= :foo
      @provider_options ||= {}
      @subject ||= Flo::Task.new(
        provider,
        @method_sym,
        @provider_options
      )
    end

    def provider
      @provider ||= Minitest::Mock.new
    end

    def test_calls_method_on_provider
      provider.expect(:foo, true, [{}])
      subject.call()
      provider.verify
    end

    def test_passes_on_args
      provider.expect(:foo, true, [{ bar: 1 }])
      subject.call(bar: 1)
      provider.verify
    end

    def test_merges_args_with_provider_options
      @provider_options = { baz: 2 }
      provider.expect(:foo, true, [{ bar: 1, baz: 2 }])
      subject.call(bar: 1)
      provider.verify
    end

    def test_should_raise_if_provider_options_is_not_a_hash
      @provider_options = :bar
      assert_raises(ArgumentError) { subject.call(baz: 1) }
    end

    def test_called_args_override_provider_options
      @provider_options = { bar: 2 }
      provider.expect(:foo, true, [{ bar: 1 }])
      subject.call(bar: 1)
      provider.verify
    end

    def test_procs_in_options_are_evaluated_before_provider_method_is_called
      @provider_options = { baz: Proc.new { 2 }}
      provider.expect(:foo, true, [{ bar: 1, baz: 2 }])
      subject.call(bar: Proc.new { 1 })
    end
  end
end
