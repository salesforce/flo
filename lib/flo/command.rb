require 'cleanroom'

module Flo
  class Command
    include Cleanroom
    attr_reader :tasks, :definition_lambda, :providers

    def initialize(name=[], opts={}, &blk)
      raise ArgumentError.new('.new must be called with a block defining the command') unless blk
      @performer_class = opts[:performer_class] || Flo::Performable
      @providers = opts[:providers] || {}
      @tasks = []
      @definition_lambda = convert_block_to_lambda(blk)
    end

    def validate(provider_sym, method_sym, provider_options={})
      validation_method_sym = "validate_#{method_sym}".to_sym
      tasks << performer_class.new(provider_sym, validation_method_sym, providers, provider_options)
    end
    expose :validate

    def perform(provider_sym, method_sym, provider_options={})
      tasks << performer_class.new(provider_sym, method_sym, providers, provider_options={})
    end
    expose :perform

    def call(*args)
      evaluate_command_definition(*args)
      responses = tasks.inject([]) do |arr, task|
        response = task.call(*args)
        arr << response
        return response unless response.success?
        arr
      end.last
    end

    private

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

    def cleanroom
      @cleanroom ||= self.class.send(:cleanroom).new(self)
    end

    attr_reader :performer_class

  end
end
