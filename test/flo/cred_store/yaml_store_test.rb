# Copyright © 2017, Salesforce.com, Inc.
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

      def test_element_reference_fetches_a_value_from_yaml_file
        assert_equal 'foo', ::YAML.load(File.read(yaml_fixture))['provider']['key']

        assert_equal 'foo', subject['provider']['key']
      end

    end
  end
end
