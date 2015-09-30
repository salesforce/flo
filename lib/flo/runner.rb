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
  class Runner
    include Cleanroom

    attr_reader :commands

    def initialize(opts={})
      @config = opts[:config] || Flo::Config.new
      @command_class = opts[:command_class] || Flo::Command
      @commands = opts[:command_collection] || Flo::CommandCollection.new
    end

    def load_config_file(config_file)
      evaluate_file(config_file)
    end

    def execute(command_namespace, *args)
      commands[command_namespace].call(*args)
    end

    def config
      yield(@config) if block_given?
      @config
    end
    expose :config

    def register_command(command_namespace, &blk)
      commands[command_namespace] = command_class.new(providers: config.providers, &blk)
    end
    expose :register_command

    private

    attr_reader :command_class

  end
end
