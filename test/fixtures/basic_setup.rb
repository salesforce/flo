# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require 'flo/provider/developer'

config do |cfg|
  cfg.cred_store = Flo::CredStore::YamlStore.new(File.join(FIXTURES_ROOT, "cred_example.yml"))
  cfg.provider :developer, password: cfg.creds['some_value']
end

register_command([:task, :start]) do |success: true|
  perform :developer, :is_successful, { success: state(:developer).return_true }
end
