# Copyright © 2019, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require_relative '../minitest_helper'
require 'flo/command_collection'

module Flo
  class CommandCollectionTest < Flo::UnitTest

    def subject
      @subject ||= Flo::CommandCollection.new
    end

    def test_a_single_symbol_can_be_used_as_a_storage_key
      command = Object.new
      subject[:command_name] = command
      assert_same command, subject[:command_name]
    end

    def test_selecting_a_command_that_doesnt_exist_raises_error
      assert_raises(Flo::CommandNotDefinedError) do
        subject[:undefined_command]
      end
    end

  end
end
