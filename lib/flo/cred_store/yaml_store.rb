# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require 'yaml'
require 'flo'
require 'flo/cred_store/creds'

module Flo

  MissingProviderError = Class.new(Flo::Error)

  module CredStore
    class YamlStore

      def initialize(location=nil)
        @location = location || File.join(Dir.home, '.flo_creds.yml')
      end

      # Returns the credentials for the requested provider
      # @param provider_sym [Symbol]
      # @returns Hash
      #
      def credentials_for(provider_sym)
        Flo::CredStore::Creds.new(full_credentials_hash[provider_sym])
      end

      private

      def full_credentials_hash
        @full_credentials_hash ||= YAML.load(File.read(@location))
      end
    end
  end
end
