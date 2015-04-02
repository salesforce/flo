require_relative '../minitest_helper'
require 'flo/performable'

module Flo
  class PerformableTest < Flo::UnitTest

    def subject
      @subject ||= Flo::Performable.new(:mock_provider, :example_command, {})
    end

    def providers_mock
      @providers_mock ||= {mock_provider: mock_provider}
    end

    def mock_provider
      @mock_provider ||= Minitest::Mock.new
    end

    def test_execute_returns_provider_response
      expected_response = Object.new
      mock_provider.expect(:example_command, expected_response)
      response = subject.execute(providers_mock)

      assert_same expected_response, response
      mock_provider.verify
    end

    def test_execute_with_args_passes_args_to_provider
      expected_response = Object.new
      args = {foo: :bar}
      mock_provider.expect(:example_command, expected_response, [args])
      response = subject.execute(providers_mock, [args])

      assert_same expected_response, response
      mock_provider.verify
    end

  end
end