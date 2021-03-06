# Copyright © 2019, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require 'flo/provider/base'
require 'ostruct'

module Flo
  module Provider
    Response = Struct.new(:success?)
    class Developer < Flo::Provider::Base

      option :password, nil, required: false

      def is_successful(opts={})
        success = opts[:success].nil? ? true : opts[:success]
        Flo::Provider::Response.new(success)
      end

      def return_true
        true
      end

      def has_option(opts={})
        Flo::Provider::Response.new(options.include?(opts[:option]))
      end
    end
  end
end
