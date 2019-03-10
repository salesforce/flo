# Copyright © 2019, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

module Flo
  module Provider
    MissingOptionError = Class.new(StandardError)
    OptionDefinition = Struct.new(:default, :required)

    # @abstract Subclass and use {.option} to declare initialize options
    # A base provider class that all custom providers should inherit from.
    #
    class Base

      attr_writer :cred_store

      # Creates an instance of a provider
      # @param opts [Hash] Arbitrary array of options defined by the provider
      #   using the {.option} method
      # @raise [MissingOptionError] if a required option is not provided.  Error
      #   message will state which options are missing.
      #
      def initialize(opts={})
        # @options = allow_whitelisted(opts, @@option_keys)
        @options = {}
        self.class.option_keys.each do |key, definition|
          @options[key] = opts.fetch(key, definition.default)
        end

        missing_required = self.class.option_keys.select {|_k,v| v.required }.keys - @options.select { |_k,v| !v.nil? }.keys
        unless missing_required.empty?
          raise MissingOptionError.new("#{self.class.name} invoked without required options: #{missing_required.join(' ')}")
        end
      end

      # Declare an option to be passed in when declaring the provider in the
      # .flo file
      # @param name [Symbol] The name of the option
      # @param default Default value for the option if none is provided
      # @option args [Boolean] :required (false) Whether the option is required.
      #   A MissingOptionError will be raised if a provider is instantiated
      #   without a required argument
      #
      def self.option(name, default=nil, args={})
        option_keys[name] = OptionDefinition.new(default, args[:required] == true)
      end

      # Hash of option definitions.  Add to this hash using the {.option}
      # method.
      #
      # @return [Hash{Symbol => OptionDefiniton}]
      def self.option_keys
        @option_keys ||= {}
      end

      private

      attr_reader :options
    end
  end
end
