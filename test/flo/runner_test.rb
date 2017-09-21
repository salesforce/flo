# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require_relative '../minitest_helper'
require 'flo/runner'

module Flo
  class RunnerTest < Flo::UnitTest

    def subject
      @subject ||= Flo::Runner.new(
        config: config_mock,
        command_class: command_class_mock,
        command_collection: command_collection_mock
      )
    end

    def config_mock
      @config_mock ||= Minitest::Mock.new
    end

    def command_class_mock
      @command_class_mock ||= Minitest::Mock.new
    end

    def command_collection_mock
      @command_collection_mock ||= {}
    end

    def config_file_fixture
      @config_file_fixture ||= File.expand_path(File.join(FIXTURES_ROOT, 'basic_setup.rb'))
    end

    def test_config_returns_config_instance
      # Minitest::Mock undefines #equal?, which causes #assert_same to raise
      assert_equal config_mock.object_id, subject.config.object_id
    end

    def test_passing_block_to_config_yields_config_to_block
      config_mock.expect(:foo, true)

      subject.config do |cfg|
        cfg.foo
      end

      config_mock.verify
    end

    def test_register_command_adds_new_command_to_collection
      new_command = Object.new
      command_class_mock.expect(:new, new_command, [{ providers: {} }])

      config_mock.expect(:providers, {})

      subject.register_command(:foo) { }

      assert_equal new_command, subject.commands[:foo][:command]

      command_class_mock.verify
    end

    def test_execute_calls_command_with_args
      args = {foo: :bar}
      providers_hash = Object.new
      new_command = lambda { |_args| true }

      command_class_mock.expect(:new, new_command, [{ providers: providers_hash }])
      config_mock.expect(:providers, providers_hash)

      subject.register_command(:foo)

      subject.execute(:foo, args)
    end

    def test_load_config_file_evals_file
      config_mock.expect(:provider, true, [:developer])
      subject.load_config_file(File.join(FIXTURES_ROOT, 'one_config_call.rb'))

      config_mock.verify
    end

    def test_load_default_config_files_loads_available_config_files
      File.stub(:exist?, true) do
        loaded_files = []
        subject.stub(:load_config_file, lambda { |file| loaded_files << file } ) do

          subject.load_default_config_files
        end

        assert_equal [File.join(Dir.pwd, '.flo'), File.join(Dir.home, '.flo')], loaded_files
      end
    end

  end
end
