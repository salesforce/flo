require 'flo'
require 'flo/command'
require 'flo/command_collection'
require 'flo/performable'

module Flo
  class Runner

    attr_reader :commands

    def initialize(opts={})
      @config = opts[:config] || Flo::Config.new
      @command_class = opts[:command_class] || Flo::Command
      @commands = opts[:command_collection] || Flo::CommandCollection.new
    end

    def load_config_file(config_file)
      instance_eval(File.read(config_file), config_file, 0)
    end

    def execute(command_namespace, args={})
      commands[command_namespace].execute(args, config.providers)
    end

    def config
      yield(@config) if block_given?
      @config
    end

    def register_command(command_namespace, &blk)
      commands[command_namespace] = command_class.new(command_namespace, &blk)
    end

    private

    attr_reader :command_class

  end
end
