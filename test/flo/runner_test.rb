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
      @command_collection_mock ||= Minitest::Mock.new
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
      command_proc = ->(*args) { :your_command_config_here }
      command_class_mock.expect(:new, new_command, [:foo])

      command_collection_mock.expect(:[]=, new_command, [:foo, new_command])
      command_collection_mock.expect(:[], new_command, [:foo])

      subject.register_command(:foo, &command_proc)

      assert_equal new_command, subject.commands[:foo]

      command_class_mock.verify
      command_collection_mock.verify
    end

    def test_register_command_namespaced_adds_new_command_to_collection
      new_command = Object.new
      command_proc = ->(*args) { :your_command_config_here }
      command_class_mock.expect(:new, new_command, [[:foo, :bar]])

      command_collection_mock.expect(:[]=, new_command, [[:foo, :bar], new_command])
      command_collection_mock.expect(:[], new_command, [:foo, :bar])

      subject.register_command([:foo, :bar], &command_proc)

      assert_equal new_command, subject.commands[:foo, :bar]

      command_class_mock.verify
      command_collection_mock.verify
    end

    def test_execute_calls_command_with_args
      args = {foo: :bar}
      providers_hash = Object.new
      new_command = Minitest::Mock.new
      new_command.expect(:execute, true, [args, providers_hash])
      command_class_mock.expect(:new, new_command, [:foo])
      config_mock.expect(:providers, providers_hash)

      command_collection_mock.expect(:[]=, new_command, [:foo, new_command])
      command_collection_mock.expect(:[], new_command, [:foo])

      subject.register_command(:foo)

      subject.execute(:foo, args)

      new_command.verify
      command_collection_mock.verify
    end

    def test_load_config_file_evals_file
      config_mock.expect(:provider, true, [:developer])
      subject.load_config_file(File.join(FIXTURES_ROOT, 'one_config_call.rb'))

      config_mock.verify
    end


  end
end
