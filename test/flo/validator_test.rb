require_relative '../minitest_helper'
require 'flo/validator'

module Flo
  class ValidatorTest < Flo::UnitTest

    def subject
      @subject_args ||= [:mock, :true]
      @subject ||= Flo::Validator.new(*@subject_args)
    end

    def test_execute_sends_responsibility_to_runner
      subject
      skip
    end

  end
end