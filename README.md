# Flo
[![Gem Version](https://badge.fury.io/rb/flo.svg)](https://badge.fury.io/rb/flo) [![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/codeclimate/codeclimate) [![Build Status](https://semaphoreci.com/api/v1/justinpowers/flo/branches/master/shields_badge.svg)](https://semaphoreci.com/justinpowers/flo)


Flo is a local workflow automation tool that helps you get things done.  This gem contains the core functionality for Flo, plugins for interacting with various systems can be found in separate provider gems.

## Installation

Add this line to your application's Gemfile:

```shell
gem 'flo'
```
And then execute:

```shell
$ bundle
```
Or install it yourself as:

```shell
$ gem install flo
```

## Documentation
http://www.rubydoc.info/github/salesforce/flo/

## Usage

### Command line usage

COMING SOON!
A command line parser has not yet been added.  If you require a script that can be invoked from the command line, you can create a ruby script that creates and runs a `Flo::Runner` instance.  See [Ruby script usage](#Ruby_script_usage) for more details.

### Ruby script usage

Flo has been built with the intention of being easy to use within ruby scripts.  `Flo::Runner` is responsible for parsing your custom configuration and invoking the commands.  See the following example:

```ruby
require 'flo'

runner = Flo::Runner.new

# Load your custom command configurations (see .flo file section for more details)
runner.load_config_file(File.join(__dir__,'.flo'))

# Run the something:useful command defined in the .flo file
response = runner.execute([:something, :useful], id: '123')
```


## .flo configuration file

Flo makes very few assumptions about what you want to use it for, or how you want to use it.  In order for you to use it for anything useful, you will need to provide it some configuration.  This is accomplished by loading one or more .flo configuration files.  See [Ruby script usage](#Ruby_script_usage) for an example of how to load the file.  The .flo file is evaluated in ruby in a cleanroom environment (see the [cleanroom gem](https://github.com/sethvargo/cleanroom) for more information), so you can require any gems or modules needed to accomplish the functionality you are looking for.  There are two required sections:
* configuration
* command registration

### Configuration

Before you can do anything useful in your .flo file, you have to declare providers.  You can do so using a config block, for example:

```ruby
config do |cfg|
  cfg.provider :developer, {configuration_option: 'value' }
end
```

### Command registration

You can register any number of commands.  Commands are namespaced to make it easier to group together similar commands.  Within a command declaration you declare a set of tasks that will be executed in order when the command is invoked.  Here is an overly simple example for starting a feature branch that only uses a single provider.  In typical usage you would likely utilize multiple providers within a single command.

```ruby
# Registers a command for starting a feature - feature:start.  This command has
# one required argument: 'feature_name'.  Note that in order for this to work,
# you will need to declare the git_flo provider in the config section.
register_command([:feature, :start]) do |feature_name: nil|

  # During command execution, perform the :check_out_or_create_branch method on
  # the git_flo provider, passing in the :from and :name arguments
  perform :git_flo, :check_out_or_create_branch, { from: 'master', name: feature_name }
end
```

## Contributing

1. Fork it (http://github.com/your-github-username/flo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

>Copyright (c) 2017, Salesforce.com, Inc.
>All rights reserved.
>
>Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
>
>* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
>
>* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
>
>* Neither the name of Salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
>
>THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
