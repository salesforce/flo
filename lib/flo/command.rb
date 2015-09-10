require 'cleanroom'

module Flo
  class Command
    include Cleanroom

    def initialize(opts={}, &blk)
      raise ArgumentError.new('.new must be called with a block defining the command') unless blk
      @providers = opts[:providers] || {}
      @tasks = []
      @definition_lambda = convert_block_to_lambda(blk)
    end

    def perform(provider_sym, method_sym, provider_options={})
      tasks << [providers[provider_sym].method(method_sym), provider_options]
    end
    expose :perform

    alias :validate :perform
    expose :validate

    def call(args={})
      evaluate_command_definition(args)
      response = tasks.map do |command, options|
        response = command.call(options.merge(args))

        # bail early if the command failed
        return response unless response.success?
        response
      end.last
    end

    private

    attr_reader :tasks, :definition_lambda, :providers

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


  end
end
