module Flo
  class Performable

    attr_accessor :provider_sym, :method_sym, :options

    def initialize(provider_sym, method_sym, options={})
      @provider_sym = provider_sym
      @method_sym = method_sym
      @options = options
    end

    def execute(providers_hash, args=[])
      providers_hash[@provider_sym].public_send(method_sym, *args)
    end

  end
end
