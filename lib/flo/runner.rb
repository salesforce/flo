require 'flo'
require 'flo/command'
require 'flo/performable'

module Flo
  class Runner

    def initialize(config_file=nil)
      require config_file
    end

    def execute(command_namespace, args={})
      raise NotImplementedError # TODO: Implement this
    end

  end
end
