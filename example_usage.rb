# Note - This is a scratchpad for designing the desired API for Flo.  See live examples in test/fixtures

require 'jira-flo'

config do |cfg|
  cfg.provider :jira, {api_key: 'foo', jira_id: jira_id_proc} #Flo::Provider::Jira
end

# Can pass in procs as args: { jira_id: -> { BRANCH_REGEX.match(git.branch_name)[:ticket_id] } }

register_command([:ticket, :submit]) do |state|
  # validate :provider, :validation_method, args = {}
  validate :jira, :status_greater_than, {status: :in_development}
  # perform :provider, :method, args = {}
  perform :git, :push
  # validate :provider, :method # should only run if the previous perform completes
  perform :github, :create_pull_request, { description: state[:jira].title }
  perform :jira, :update_field, { pull_request: state[:github].pull_request_url }
end

# Example gems to include in Gemfile
# gem 'flo'
# gem 'jira-flo'
# gem 'git-flo'
# gem 'github-flo'