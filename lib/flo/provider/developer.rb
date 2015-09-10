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
    end
  end
end