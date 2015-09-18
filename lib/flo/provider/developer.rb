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
        Flo::Provider::Response.new(true)
      end

      def echo(opts={})
        puts opts.inspect
        Flo::Provider::Response.new(true)
      end
    end
  end
end