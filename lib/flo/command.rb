require 'cleanroom'

module Flo
  class Command
    include Cleanroom

    def initialize(opts={}, &blk)
      raise ArgumentError.new('.new must be called with a block defining the command') unless blk
      @state_class = opts[:state_class] || Flo::State
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

    def state(provider_sym)
      state_class.new(providers[provider_sym])
    end
    expose :state

    def call(args={})
      evaluate_command_definition(args)
      response = tasks.map do |task, options|
        combined_args = evaluate_proc_values(options.merge(args))

        response = task.call(combined_args)
        # response = task.call(options.merge(args))

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
