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

require 'cleanroom'

module Flo

  # Definition of a single command.  In general you should not call {#initialize Command.new}
  # directly, but instead define the command using {Runner#register_command}.
  #
  # When a command is generated using {Runner#register_command} (typically in a
  # flo configuration file), only the DSL methods will be available
  #
  class Command

    include Cleanroom

    # Creates a new command instance
    # @option  opts [Hash] providers ({}) Providers that the command will need
    #   access to
    #
    # @yield [args*]The block containing the definition for the command.
    #   Arguments passed into {#call} are available within the block
    #
    def initialize(opts={}, &blk)
      raise ArgumentError.new('.new must be called with a block defining the command') unless blk
      @state_class = opts[:state_class] || Flo::State
      @providers = opts[:providers] || {}
      @tasks = []
      @definition_lambda = convert_block_to_lambda(blk)
    end

    # @api dsl
    # DSL method: Define a task that will be performed during the execution stage when
    # {#call} is invoked.
    # @param provider_sym [Symbol] The provider to send the message to
    # @param method_sym [Symbol] The method you wish to call on the provider
    # @param provider_options [Hash] A hash of options to be passed when
    #   invoking the method on the provider.  Any lambda values will be called
    #   during the execution stage when #{#call} is invoked
    #
    def perform(provider_sym, method_sym, provider_options={})
      tasks << [providers[provider_sym].method(method_sym), provider_options]
    end
    expose :perform

    alias :validate :perform
    expose :validate

    # @api dsl
    # DSL method: Returns an object representing the current state of the provider during
    # the execution stage when {#call} is invoked.  Any methods called on the
    # {State} instance will return a lambda.  This is intended to be used in the
    # parameters passed to the {#perform} method, as you often want these
    # parameters lazily evaluated during the execution stage, not when the
    # definition is parsed.
    # @param provider_sym [Symbol] The provider that you wish to query
    #
    # @return [State] An object that will return a lambda, delegating the method
    #   call to the provider specified
    #
    def state(provider_sym)
      state_class.new(providers[provider_sym])
    end
    expose :state

    # Invoke the command that has already been defined.
    #
    # This will run the command, processing any tasks defined by {#perform} and
    # {#validate} in order, stopping execution if any of the tasks fails.
    # Arguments passed in here will be merged with the provider options defined
    # in each task.
    # @param args [Hash] arguments to be passed to each task
    #
    def call(args={})
      evaluate_command_definition(args)
      response = tasks.map do |task, options|
        combined_args = evaluate_proc_values(options.merge(args))

        response = task.call(combined_args)

        # bail early if the task failed
        return response unless response.success?
        response
      end.last
    end

    private

    attr_reader :tasks, :definition_lambda, :providers, :state_class

    def evaluate_command_definition(*args)
      cleanroom.instance_exec(*args, &definition_lambda)
    end

    def convert_block_to_lambda(blk)
      # jruby and rubinius can convert a proc directly into a lambda
      if (converted_block = lambda(&blk)).lambda?
        converted_block
      else
        # Otherwise, hacky method to take advantage of #define_method's automatic lambda conversion
        cleanroom.define_singleton_method(:_command_definition, &blk)
        cleanroom.method(:_command_definition).to_proc
      end
    end

    def evaluate_proc_values(args={})
      hsh = {}
      args.each do |k, v|
        hsh[k] = v.is_a?(Proc) ? v.call : v
      end
      hsh
    end

    def cleanroom
      @cleanroom ||= self.class.send(:cleanroom).new(self)
    end


  end
end
