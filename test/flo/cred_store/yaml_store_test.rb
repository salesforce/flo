# Copyright © 2019, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require_relative '../../minitest_helper'
require 'flo/cred_store/yaml_store'

module Flo
  module CredStore
    class YamlStoreTest < Flo::UnitTest

      def subject
        @subject ||= Flo::CredStore::YamlStore.new(yaml_fixture)
      end

      def yaml_fixture
        @yaml_fixture ||= File.join(FIXTURES_ROOT, 'cred_example.yml')
      end

      def test_credentials_for_returns_credentials_object
        refute_nil ::YAML.load(File.read(yaml_fixture))[:provider]
        assert_kind_of Flo::CredStore::Creds, subject.credentials_for(:provider)
      end

      def test_credentials_for_returns_creds_object_if_provider_is_not_present
        assert_nil ::YAML.load(File.read(yaml_fixture))[:missing_provider]

        assert_kind_of Flo::CredStore::Creds, subject.credentials_for(:missing_provider)
      end

    end
  end
end
