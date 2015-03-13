require_relative '../minitest_helper'
require 'flo'
require 'flo/provider/developer'

class FloTest < Flo::UnitTest

  def subject
    @subject = Flo
  end
  def test_config_initializes_providers
    subject.config do |cfg|
      cfg.provider :developer
    end

    assert_equal Flo::Provider::Developer, subject.providers[:developer]
  end

  def test_raises_helpful_error_if_provider_not_required
    assert_raises(Flo::MissingRequire) do
      subject.config do |cfg|
        cfg.provider :doesnt_exist
      end
    end
  end

  def test_should_camelcase_provider_symbol
    skip "Not yet implemented"
  end

  def test_register_command_adds_command_to_commands_attribute
    cmd_class = Minitest::Mock.new
    command_instance = Object.new
    cmd_class.expect(:new, command_instance, [[:example_command]])
    Flo.register_command(:example_command, command_class: cmd_class)

    assert_same command_instance, Flo.commands[:example_command]
  end
end