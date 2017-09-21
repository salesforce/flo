# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require_relative '../../minitest_helper'
require 'flo/cred_store/yaml_store'

module Flo
  module CredStore
    class CredsTest < Flo::UnitTest

      def subject
        @subject ||= Flo::CredStore::Creds.new(key: 'foo')
      end

      def test_element_reference_fetches_a_value_from_yaml_file
        assert_equal 'foo', subject[:key]
      end

      def test_element_reference_raises_on_missing_value
        assert_raises(Flo::MissingCredentialError) do
          subject[:missing_key]
        end
      end

    end
  end
end
