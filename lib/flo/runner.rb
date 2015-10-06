# Copyright (c) 2015, Salesforce.com, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# * Neither the name of Salesforce.com nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'flo'
require 'flo/command'
require 'flo/command_collection'
require 'flo/state'
require 'flo/config'
require 'cleanroom'

module Flo

  # This is the main class for instantiating and performing Flo commands.  If
  # you are wanting to interact with Flo via a ruby script, this is the class
  # you want.  Utilizing Flo through the command line interface will invoke this
  # class after all of the argument parsing is complete.
  #
  # @example
  #     runner = Runner.new
  #     runner.load_config_file('path/to/config/file')
  #     runner.execute([:issue, :submit], id: '1234', submitter: 'John Doe')
  #
  # @attr_reader commands [CommandCollection] List of commands currently defined
  #
  class Runner
    include Cleanroom

    attr_reader :commands

    # Creates a new runner.  This object is generally useless until you load
    # some configuration into it, typically using {#load_config_file}
    #
    def initialize(opts={})
      @config = opts[:config] || Flo::Config.new
      @command_class = opts[:command_class] || Flo::Command
      @commands = opts[:command_collection] || Flo::CommandCollection.new
    end

    # Open and parse a file containing flo configuration.  This file is
    # evaluated within a cleanroom.  See the {https://github.com/sethvargo/cleanroom cleanroom gem}
    # for more information.
    # @param config_file [String] path to the flo configuration file
    #
    def load_config_file(config_file)
      evaluate_file(config_file)
    end

    # Executes the command specified, with the arguments specified
    # @param command_namespace [Array<Symbol>] An array containing the name of
    #   the command as a symbol, including the namespace.  For example, the
    #   command "issue submit" would become [:issue, :submit]
    # @param args={} [Hash] Options that will get passed to the command
    #
    def execute(command_namespace, args={})
      commands[command_namespace].call(args)
    end

    # @api dsl
    # DSL method: Returns the instance of {Config} associated with this runner.  Exposes the
    # {Config} instance if a block is used
    #
    # @yield [Config]
    #
    # @return [Config]
    #
    def config
      yield(@config) if block_given?
      @config
    end
    expose :config

    # @api dsl
    # DSL method: Creates and defines a {Command}, adding it to the command collection.
    # Definition for the command should happen inside of the required block.
    # See {Command} for methods available within the block.
    # @param command_namespace [Array<Symbol>] Array of symbols representing the
    #   command including the namespace
    # @yield [args*]The block containing the definition for the command.
    #   Arguments passed into {#execute} are available within the block
    #
    def register_command(command_namespace, &blk)
      commands[command_namespace] = command_class.new(providers: config.providers, &blk)
    end
    expose :register_command

    private

    attr_reader :command_class

  end
end
