require "flo/version"

module Flo
  MissingRequireError = Class.new(StandardError)

  def self.providers
    @providers ||= {}
  end

  def self.commands
    @commands ||= {}
  end

  def self.config
    yield self
  end

  def self.provider(provider_name)
    klass_name = "Flo::Provider::#{provider_name.capitalize}"
    providers[provider_name.to_sym] = const_get(klass_name)
  rescue NameError => e
    raise MissingRequireError.new("#{klass_name} is not loaded.  Please require the library before use")
  end

  def self.register_command(command_name, opts={}, &blk)
    command_name = [command_name] unless command_name.is_a?(Array)
    command_klass = opts[:command_class] || Flo::Command
    commands[symbolize_command_name(command_name)] = command_klass.new(command_name, &blk)
  end

  private

  def self.symbolize_command_name(name_array)
    name_array.join('_').to_sym
  end
end
