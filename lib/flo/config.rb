# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require 'flo/cred_store/yaml_store'

module Flo
  MissingRequireError = Class.new(StandardError)

  # Instantiates and stores providers for use in command definitions
  #
  # @attr_reader providers [Hash] Hash of provider instances
  #
  class Config
    attr_writer :cred_store
    attr_reader :providers

    def initialize
      @providers = {}
    end

    # Instantiate a provider and add it to the {#providers} collection
    # @param provider_sym [Symbol]
    # @param options [Hash] Options to be passed to provider initialization
    # @yield Yields the block to the provider initializer, in case the provider
    # accepts a block
    #
    def provider(provider_sym, options={}, &blk)
      @providers[provider_sym] = provider_class(provider_sym).new(options, &blk)
    end

    def cred_store
      @cred_store ||= Flo::CredStore::YamlStore.new
    end

    alias :creds :cred_store

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
