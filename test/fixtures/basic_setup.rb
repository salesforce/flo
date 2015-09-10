require 'flo/provider/developer'

config do |cfg|
  cfg.provider :developer
end

register_command([:task, :start]) do |success: true|
  perform :developer, :is_successful, { success: true }
end
