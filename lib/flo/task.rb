# Copyright © 2019, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

module Flo

  # Definition of a task performed by a {Command}.
  #
  class Task

    # Creates a new Task instance
    #
    # @param [Provider] provider The provider to send the message to
    # @param [Symbol] The method you wish to call on the provider
    # @param [Hash] provider_options={} A hash of options to be passed when
    #   invoking the method on the provider.  Any lambda values will be called
    #   during the execution stage when {#call} is invoked
    #
    def initialize(provider, method_sym, provider_options={})
      @provider = provider
      @method_sym = method_sym

      raise ArgumentError.new("Expected provider_options to be a Hash") unless provider_options.is_a? Hash
      @provider_options = provider_options
    end

    # Call invokes the task on the provider instance.  Additional parameters can be
    # passed in that are merged into the parameters that were provided in {initialize}.
    # Proc values will be evaluated before being passed to the provider.
    #
    # @param [Array] args=[] Additional arguments to pass to the provider method
    # @return [#success?] Response of the provider's method
    def call(args=[])
      raise ArgumentError.new("Expected Array") unless args.is_a? Array
      @provider.public_send(method_sym, *merged_evaluated_args(args.dup))
    end

    private
    attr_reader :provider, :method_sym, :provider_options

    def merged_evaluated_args(args)
      unless args[-1].is_a? Hash
        args.push Hash.new
      end

      args[-1] = provider_options.merge(args[-1])
      evaluate_proc_values(args)
    end

    # For each value in the args array, evaluate any procs.
    # If the value is a hash, evaluate any values in the hash
    # that are procs.
    def evaluate_proc_values(args=[])
      args.collect do |arg|
        case arg
        when Proc
          arg.call
        when Hash
          hsh = {}
          arg.each do |k, v|
            hsh[k] = v.is_a?(Proc) ? v.call : v
          end
          hsh
        else
          arg
        end
      end
    end
  end
end
