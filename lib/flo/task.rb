# Copyright (c) 2015, Salesforce.com, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# * Neither the name of Salesforce.com nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

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
