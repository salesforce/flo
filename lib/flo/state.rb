module Flo
  class State

    def initialize(provider)
      @provider = provider
    end

    def method_missing(meth_sym, *args)
      [provider.method(meth_sym), args]

      lambda do
        provider.method(meth_sym).call(*args)
      end
    end

    private

    attr_reader :provider
  end
end