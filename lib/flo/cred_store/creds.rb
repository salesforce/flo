# Copyright © 2019, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

module Flo
  MissingCredentialError = Class.new(Flo::Error)

  module CredStore
    class Creds

      def initialize(credentials)
        @credentials = credentials
      end

      # Returns the credential referenced by the key provided
      # @param key [Symbol, String]
      # @raises Flo::MissingCredentialError if key does not exist
      #
      def [](key)
        raise Flo::MissingCredentialError unless @credentials.key?(key)

        @credentials[key]
      end
    end
  end
end
