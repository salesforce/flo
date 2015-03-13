module Flo
  class Performable

    attr_accessor :provider, :method_sym, :options

    def initialize(provider, method_sym, options={})
      @provider = provider
      @method_sym = method_sym
      @options = options
    end

    def execute
      @provider.public_send(method_sym)
    end

  end
end
