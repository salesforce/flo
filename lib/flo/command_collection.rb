# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

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
