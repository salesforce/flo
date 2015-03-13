require_relative '../minitest_helper'
require 'flo/runner'
require 'flo'

module Flo
  class RunnerTest < Flo::UnitTest

    def subject
      @subject ||= Flo::Runner.new(File.join(TEST_ROOT, 'fixtures/basic_setup.rb'))
    end

    def test_execute_returns_success
      response = subject.execute([:task, :start], {})

      assert_equal true, response.success
    end

    def test_execute_success_is_false_when_perform_fails
      skip "Passing in args not yet implemented"
      response = subject.execute([:task, :start], {success: false})

      assert_equal false, response.success
    end

  end
end

