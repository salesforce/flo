require_relative '../minitest_helper'
require 'flo/performable'

module Flo
  class PerformableTest < Flo::UnitTest

    def subject
      @subject ||= Flo::Performable.new(mock_provider, :example_command, {})
    end

    def mock_provider
      @mock_provider ||= Minitest::Mock.new
    end

    def test_execute_returns_provider_response
      expected_response = Object.new
      mock_provider.expect(:example_command, expected_response)
      response = subject.execute

      assert_same expected_response, response
      mock_provider.verify
    end

  end
end