# Copyright © 2019, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require 'cri'

module Flo

  # Builds the command line parser and executes Flo::Runner using the commands supplied.
  # In general you should be able to create a new instance and then pass in ARGV directly
  # into {#call}.
  class Cli

    # Creates a new CLI runner instance.
    # @option opts [Class] runner_class (Runner) Class of the runner object dependency
    def initialize(opts={})
      @runner_class = opts[:runner_class] || Runner
    end

    # Runs a command using args directly from ARGV.
    # @param argv [Array<String>] An array of strings.  Typically you would pass in ARGV directly.
    #   The first value should be the name of the command
    #
    def call(argv)
      generate_commands.run(argv)
    end

    private

    attr_reader :runner_class

    def generate_commands
      flo_runner = runner_class.new
      flo_runner.load_default_config_files

      flo_runner.commands.each do |cmd_name, cmd|

        main_command.define_command do
          options = cmd[:command].required_parameters

          unless cmd[:command].optional_parameters.empty?
            options << '[options]'

            cmd[:command].optional_parameters.each do |param|
              optional(nil, param, param.to_s.tr('_', ' '))
            end
          end

          name(cmd_name)
          usage("#{cmd_name} #{options.join(' ')}")
          summary(cmd[:summary])
          description(cmd[:description])

          run do |opts, arguments, command|
            flo_runner.execute(command.name, arguments.to_a.push(opts))
          end
        end
      end

      main_command
    end

    def main_command
      @main_command ||= Cri::Command.new_basic_root.modify do
        name        'flo'
        usage       'flo [command]'
        summary     'Local workflow automation'
        description 'Use `flo help [command]` for usage on individual commands'

        default_subcommand 'help'
      end
    end

  end
end
