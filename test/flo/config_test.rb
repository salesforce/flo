# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require_relative '../minitest_helper'
require 'flo/config'
require 'yaml'

module Flo
  class ConfigTest < Flo::UnitTest

    def subject
      @subject ||= Flo::Config.new
    end

    def test_provider_instantiates_new_provider
      assert_equal({}, subject.providers)
      subject.provider(:mock_provider)
      assert_kind_of Flo::Provider::MockProvider, subject.providers[:mock_provider]
    end

    def test_raises_helpful_error_if_provider_not_required
      assert_raises(Flo::MissingRequireError) do
        subject.provider :doesnt_exist
      end
    end

    def test_cred_store_defaults_to_yaml
      assert_kind_of Flo::CredStore::YamlStore, subject.cred_store
    end

    def test_cred_store_can_be_assigned
      expected_cred_store = Object.new

      subject.cred_store = expected_cred_store

      assert_same expected_cred_store, subject.cred_store
    end
  end

  module Provider
    class MockProvider
      def initialize(args={})
      end
    end
  end
end
