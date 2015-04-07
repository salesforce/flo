require_relative '../minitest_helper'
require 'flo/runner'
require 'flo/config'

module Flo
  class RunnerIntegrationTest < Flo::UnitTest

    def subject
      @subject ||= begin
        subj = Flo::Runner.new
        subj.load_config_file(File.join(FIXTURES_ROOT, 'basic_setup.rb'))
        subj
      end
    end

    def test_execute_returns_success
      response = subject.execute([:task, :start])

      assert_equal true, response.success?
    end

    def test_execute_success_is_false_when_perform_fails
      response = subject.execute([:task, :start], success: false)

      assert_equal false, response.success?
    end

  end
end

