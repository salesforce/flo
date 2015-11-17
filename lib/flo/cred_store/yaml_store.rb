# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require 'yaml'

module Flo
  module CredStore
    class YamlStore

      def initialize(location=nil)
        @location = location || File.join(Dir.home, '.flo_creds.yml')
      end

      def [](key)
        YAML.load(File.read(@location))[key]
      end

    end
  end
end
