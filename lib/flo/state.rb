# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

module Flo
  class State

    def initialize(provider)
      @provider = provider
    end

    def method_missing(meth_sym, *args)
      lambda do
        provider.method(meth_sym).call(*args)
      end
    end

    private

    attr_reader :provider
  end
end
