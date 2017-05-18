# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require 'ostruct'

module Flo
  module Provider
    Response = Struct.new(:success?)
    class Developer

      def initialize(options={})

      end

      def is_successful(opts={})
        success = opts[:success].nil? ? true : opts[:success]
        Flo::Provider::Response.new(success)
      end

      def return_true
        true
      end

      def echo(opts={})
        puts opts.inspect
        Flo::Provider::Response.new(true)
      end
    end
  end
end
