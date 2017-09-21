# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require 'forwardable'
require 'flo/error'

module Flo

  CommandNotDefinedError = Class.new(Flo::Error)

  # A collection of commands.  Behaves like a Hash, except that fetching a key that does
  # not exist raises an error
  class CommandCollection
    extend Forwardable
    def_delegators :@commands, :each, :[]=

    def initialize
      @commands = {}
    end

    # Returns the value corresponding to the key.  Identical to accessing Hash values, except
    # that fetching a value that does not exist raises an error
    # @param key [String] Name of the command
    # @raises Flo::CommandNotDefinedError if the command does not exist
    #
    def [](key)
      raise CommandNotDefinedError.new("#{key} command is not defined") unless @commands.has_key?(key)
      @commands[key]
    end

  end
end
