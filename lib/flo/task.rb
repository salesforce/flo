# Copyright © 2017, Salesforce.com, Inc.
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

      raise ArgumentError.new("Expected provider_options to be a hash") unless provider_options.is_a? Hash
      @provider_options = provider_options
    end

    # Call invokes the task on the provider instance.  Additional parameters can be
    # passed in that are merged into the parameters that were provided in {initialize}.
    # Proc values will be evaluated before being passed to the provider.
    #
    # @param [Hash] args={} Additional arguments to pass to the provider method
    # @return [#success?] Response of the provider's method
    def call(args={})
      @provider.public_send(method_sym, merged_evaluated_args(args))
    end

    private
    attr_reader :provider, :method_sym, :provider_options

    def merged_evaluated_args(args)
      evaluate_proc_values(provider_options.merge args)
    end

    def evaluate_proc_values(args={})
      hsh = {}
      args.each do |k, v|
        hsh[k] = v.is_a?(Proc) ? v.call : v
      end
      hsh
    end
  end
end
