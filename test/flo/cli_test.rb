# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require_relative '../minitest_helper'
require 'flo/cli'
require 'ostruct'

module Flo
  class CliTest < Flo::UnitTest

    def subject
      @subject ||= begin
        runner_class_mock = OpenStruct.new(new: runner_mock)
        Flo::Cli.new(runner_class: runner_class_mock)
      end
    end

    def runner_mock
      @runner_mock ||= begin
        mock = Minitest::Mock.new
        mock.expect(:load_default_config_files, true)
        mock
      end
    end

    def test_call_without_options_returns_help
      runner_mock.expect(:commands, {})

      # This is a portion of the output from the help command.
      # We're only asserting that it outputs some help text
      assert_output(/Use `flo help \[command\]` for usage on individual commands/, nil) do
        subject.call([])
      end

      runner_mock.verify
    end

    def test_call_runs_command
      runner_mock.expect(:commands, { 'expected_command' => empty_command } )
      runner_mock.expect(:execute, true, ['expected_command', Array])

      subject.call(['expected_command'])

      runner_mock.verify
    end

    def test_help_includes_command_description
      cmd = empty_command
      cmd[:description] = 'This is the description'

      runner_mock.expect(:commands, { 'expected_command' => cmd } )

      assert_output(/This is the description/, nil) do
        subject.call(['help', 'expected_command'])
      end
    end

    def test_help_includes_command_summary
      cmd = empty_command
      cmd[:summary] = 'This is the summary'

      runner_mock.expect(:commands, { 'expected_command' => cmd } )

      assert_output(/This is the summary/, nil) do
        subject.call(['help', 'expected_command'])
      end
    end

    def test_required_parameters_show_up_in_help
      cmd = empty_command
      cmd[:command].required_parameters = ['foo', 'bar']

      runner_mock.expect(:commands, { 'expected_command' => cmd } )

      assert_output(/USAGE\s+flo expected_command foo bar/, nil) do
        subject.call(['help', 'expected_command'])
      end
    end

    def test_optional_parameters_show_up_in_help
      cmd = empty_command
      cmd[:command].optional_parameters = [:foo, :bar]

      runner_mock.expect(:commands, { 'expected_command' => cmd } )

      # The options are shown in alphabetical order
      # The output should look something like this:
      # --bar[=<value>]       bar
      # --foo[=<value>]       foo
      assert_output(/--bar\[=<value>\]\s+bar\s+--foo\[=<value>\]\s+foo/, nil) do
        subject.call(['help', 'expected_command'])
      end
    end

    def test_options_and_args_are_passed_on
      cmd = empty_command
      cmd[:command].optional_parameters = ['baz']
      runner_mock.expect(:commands, { 'expected_command' => cmd } )

      runner_mock.expect(:execute, true, ['expected_command', ['foo', 'bar', {baz: 'something'}]])

      subject.call(['expected_command', 'foo', 'bar', '--baz=something'])
    end


    def empty_command
      cmd = OpenStruct.new
      cmd.required_parameters = []
      cmd.optional_parameters = []
      { command: cmd }
    end
  end
end
