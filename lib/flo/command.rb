module Flo
  class Command
    attr_reader :tasks

    def initialize(name=[], opts={}, &blk)
      raise ArgumentError.new('.new must be called with a block defining the command') unless blk
      @performer_class = opts[:performer_class] || Flo::Performable
      @tasks = []
      instance_exec(&blk)
    end

    def validate(provider_sym, method_sym, provider_options={})
      validation_method_sym = "validate_#{method_sym}".to_sym
      tasks << performer_class.new(provider_sym, validation_method_sym, provider_options)
    end

    def perform(provider_sym, method_sym, provider_options={})
      tasks << performer_class.new(provider_sym, method_sym, provider_options={})
    end

    def execute(args, providers_hash)
      responses = tasks.inject([]) do |arr, task|
        response = task.execute(providers_hash, args)
        arr << response
        return response unless response.success?
        arr
      end.last
    end

    private

    attr_reader :performer_class

  end
end
