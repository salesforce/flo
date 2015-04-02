require_relative '../minitest_helper'
require 'flo'
require 'flo/provider/developer'

class FloTest < Flo::UnitTest

  def subject
    @subject = Flo
  end

end