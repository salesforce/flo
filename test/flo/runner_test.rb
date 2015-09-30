# Copyright (c) 2015, Salesforce.com, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# * Neither the name of Salesforce.com nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

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

      assert_equal new_command, subject.commands[:foo]

      command_class_mock.verify
    end

    def test_register_command_namespaced_adds_new_command_to_collection
      config_mock.expect(:providers, {})
      new_command = Object.new
      command_class_mock.expect(:new, new_command, [{ providers: {} }])

      @command_collection_mock = {}

      subject.register_command([:foo, :bar]) { }

      assert_equal(new_command, subject.commands[[:foo, :bar]])

      command_class_mock.verify
    end

    def test_execute_calls_command_with_args
      args = {foo: :bar}
      providers_hash = Object.new
      new_command = lambda { |args| true }

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


  end
end
