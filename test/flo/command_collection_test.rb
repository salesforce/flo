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

    def test_an_array_of_symbols_can_be_used_as_a_storage_key
      command = Object.new
      subject[:name, :spaced, :command] = command
      assert_same command, subject[:name, :spaced, :command]
    end

    def test_properly_selects_correct_command
      command1 = Object.new
      command2 = Object.new
      subject[:name, :spaced, :command1] = command1
      subject[:name, :spaced, :command2] = command2

      assert_same command1, subject[:name, :spaced, :command1]
      assert_same command2, subject[:name, :spaced, :command2]
    end

    def test_selecting_a_command_that_doesnt_exist_raises_error
      assert_raises(Flo::CommandNotDefinedError) do
        subject[:undefined_command]
      end
    end

  end
end