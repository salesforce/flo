module Flo
  MissingRequireError = Class.new(StandardError)

  class Config
    attr_reader :providers

    def initialize
      @providers = {}
    end

    def provider(provider_sym, options={}, &blk)
      @providers[provider_sym] = provider_class(provider_sym).new(options, &blk)
    end

    private

    def provider_class(provider_sym)
      klass = camel_case(provider_sym.to_s)
      klass_name = "Flo::Provider::#{klass}"
      Object.const_get(klass_name)
    rescue NameError => e
      raise MissingRequireError.new("#{klass_name} is not loaded.  Please require the library before use")
    end

    def camel_case(str)
      return str if str !~ /_/ && str =~ /[A-Z]+.*/
      str.split('_').map{|e| e.capitalize}.join
    end
  end
end