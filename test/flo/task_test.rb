# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

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
      subject.call([{bar: 1}])
      provider.verify
    end

    def test_merges_args_with_provider_options
      @provider_options = { baz: 2 }
      provider.expect(:foo, true, [{ bar: 1, baz: 2 }])
      subject.call([{bar: 1}])
      provider.verify
    end

    def test_should_raise_if_provider_options_is_not_a_hash
      @provider_options = :bar
      assert_raises(ArgumentError) { subject.call(baz: 1) }
    end

    def test_called_args_override_provider_options
      @provider_options = { bar: 2 }
      provider.expect(:foo, true, [{ bar: 1 }])
      subject.call([{bar: 1}])
      provider.verify
    end

    def test_procs_in_options_are_evaluated_before_provider_method_is_called
      @provider_options = { baz: Proc.new { 2 } }
      provider.expect(:foo, true, [:sym, :proc_result, { baz: 2 }])
      subject.call([:sym, Proc.new { :proc_result }])

      provider.verify
    end

    def test_procs_in_args_are_evaluated_before_provider_method_is_called
      @provider_options = { baz: Proc.new { 2 } }
      provider.expect(:foo, true, [{ bar: 1, baz: 2 }])
      subject.call([{bar: Proc.new { 1 }}])

      provider.verify
    end

    #Mutating the args will affect any tasks that run in the future
    def test_call_does_not_mutate_original_args
      args = [{bar: 1}].freeze
      provider.expect(:foo, true, args)
      subject.call(args)
      provider.verify
    end
  end
end
