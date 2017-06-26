# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

module Flo
  module CredStore
    class PwProtectedStore

      attr_writer :cred_file

      def initialize(opts={})
        @password = opts[:password] # If nil, should prompt interactively
        @cred_file_location = opts[:cred_file_location]
      end

      # Decrypts the credentials file and returns the credentials for the requested provider
      # @param provider_sym [Symbol]
      # @returns Hash
      #
      def credentials_for(provider_sym)
        Flo::CredStore::Creds.new(full_credentials_hash[provider_sym])
      end

      # Convenience method for producing an encrypted version of a file.  This only returns
      # the encrypted version as a string, you will have to save it yourself if desired
      # @param file_location [String]
      # @returns String
      def encrypt_file(file_location)
        crypto.encrypt(File.open(file_location)).to_s
      end

      def cred_file
        @cred_file ||= File.new(@cred_file_location || File.join(Dir.home, '.flo_creds.yml.gpg'))
      end

      # Remove password from inspect output
      def inspect
        "#<Flo::CredStore::PwProtectedStore:#{object_id} @cred_file=#{cred_file.inspect}>"
      end

      private

      attr_reader :password

      def decrypted_file
        crypto.decrypt(cred_file)
      end

      def full_credentials_hash
        @full_credentials_hash ||= YAML.load(decrypted_file.read)
      end

      def crypto
        GPGME::Crypto.new(password: @password, symmetric: true)
      end
    end
  end
end
