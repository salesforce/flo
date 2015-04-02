require 'flo/provider/developer'

config do |cfg|
  cfg.provider :developer
end

register_command([:task, :start]) do
  perform :developer, :is_successful, [ { success: true } ]
end