module Flo
  class Performable

    attr_accessor :provider_sym, :method_sym, :providers, :options

    def initialize(provider_sym, method_sym, providers, options={})
      @provider_sym = provider_sym
      @method_sym = method_sym
      @providers = providers
      @options = options
    end

    def call(*args)
      providers[@provider_sym].public_send(method_sym, *args)
    end

  end
end
