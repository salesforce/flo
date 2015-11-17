# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require_relative '../../minitest_helper'
require 'flo/cred_store/pw_protected_store'
require 'gpgme'
require 'yaml'

module Flo
  module CredStore
    class PwProtectedStoreTest < Flo::UnitTest

      def subject
        @password ||= 'blah'
        @subject ||= Flo::CredStore::PwProtectedStore.new(password: @password, cred_file_location: cred_file_location)
      end

      def encryptor
        @password ||= 'blah'
        GPGME::Crypto.new(password: @password)
      end

      def cred_file_location
        @cred_file_location ||= Tempfile.new('cred_store.yml.gpg')
      end

      # Super hacky workaround.  Must use GPG 1.4, otherwise interactive password prompt
      # will always pop up in the middle of the tests.
      def setup
        GPGME::gpgme_set_engine_info(GPGME::PROTOCOL_OpenPGP, '/usr/local/bin/gpg', nil)
      end

      def teardown
        if cred_file_location.is_a? Tempfile
          cred_file_location.close
          cred_file_location.unlink
        end
      end

      def yaml_fixture
        @yaml_fixture ||= File.join(FIXTURES_ROOT, 'cred_example.yml')
      end

      # TODO: Make this test work with GPG 2.0 or 2.1
      def test_element_reference_fetches_a_value_from_yaml_file
        fixture_content = File.read(yaml_fixture)
        assert_equal 'foo', ::YAML.load(fixture_content)['provider']['key'], "Yaml fixture doesn't contain the required value, test will fail for the wrong reason"
        encryptor.encrypt(fixture_content, symmetric: true, output: cred_file_location)

        assert_equal 'foo', subject['provider']['key'], "The key either doesn't exist or the file did not decrypt properly"
      end

      def test_can_initialize_with_file_path_string
        @cred_file_location = yaml_fixture
        assert_kind_of File, subject.cred_file
      end

      def test_inspect_does_not_reveal_password
        @password = 'should_not_be_revealed'
        refute_match /#{@password}/, subject.inspect
      end

      def test_encrypt_file_properly_encrypts_existing_file
        expected = File.read(yaml_fixture)

        encrypted_outcome = subject.encrypt_file(yaml_fixture)

        decrypted_outcome = encryptor.decrypt(encrypted_outcome).to_s
        assert_equal expected, decrypted_outcome
      end
    end
  end
end
