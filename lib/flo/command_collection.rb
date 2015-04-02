module Flo
  CommandNotDefinedError = Class.new(StandardError)
  class CommandCollection

    def initialize
      @commands = {}
    end

    def [](*key)
      raise CommandNotDefinedError.new("#{key} command is not defined") unless @commands.has_key?(key)
      @commands[key]
    end

    def []=(*key, command)
      @commands[key] = command
    end

  end
end