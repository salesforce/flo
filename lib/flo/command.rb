# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

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
      @task_class = opts[:task_class] || Flo::Task
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
      tasks << @task_class.new(providers[provider_sym], method_sym, provider_options)
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
      response = tasks.map do |task|

        response = task.call(args)

        # bail early if the task failed
        return response unless response.success?
        response
      end.last
    end

    # Returns a list of any required parameters
    #
    # Required parameters are generated automatically by inspecting the required
    # parameters for the definition lambda
    # @return [Array<Symbol>] An array of symbols representing required parameters
    #
    def required_parameters
      definition_lambda.parameters.select { |key,_value| key == :req }.map { |_key,value| value }
    end


    # Returns a list of any optional parameters
    #
    # Optional parameters are generated automatically by inspecting the optional
    # parameters for the definition lambda
    # @return [Array<Symbol>] An array of symbols representing optional parameters
    #
    def optional_parameters
      definition_lambda.parameters.select { |key,_value| key == :key }.map { |_key,value| value }
    end

    private

    attr_reader :tasks, :definition_lambda, :providers, :state_class

    def evaluate_command_definition(args)
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

    def cleanroom
      @cleanroom ||= self.class.send(:cleanroom).new(self)
    end


  end
end
