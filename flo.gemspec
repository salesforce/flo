# coding: utf-8
# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flo/version'

Gem::Specification.new do |spec|
  spec.name          = "flo"
  spec.version       = Flo::VERSION
  spec.authors       = ["Justin Powers"]
  spec.email         = ["justinspowers@gmail.com"]
  spec.summary       = %q{Simple developer workflow automation}
  spec.description   = %q{Flo is a local workflow automation tool that helps you get things done.  This gem contains the core functionality for Flo, plugins for interacting with various systems can be found in separate provider gems.}
  spec.homepage      = "https://github.com/salesforce/flo"
  spec.license       = "BSD-3-Clause"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ["lib"]

  spec.add_dependency "cleanroom"
  spec.add_dependency "gpgme"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "simplecov"
end
