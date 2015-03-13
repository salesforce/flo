require 'flo/provider/developer'

Flo.config do |cfg|
  cfg.provider :developer
end

Flo.register_command([:task, :start]) do |state, args|
  perform :developer, :test, { success: true }
end