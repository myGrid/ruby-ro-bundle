#------------------------------------------------------------------------------
# Copyright (c) 2014, 2015, 2018 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ro-bundle/version'

Gem::Specification.new do |spec|
  spec.name          = "ro-bundle"
  spec.version       = ROBundle::VERSION
  spec.authors       = ["Robert Haines", "Stuart Owen", "Finn Bacall"]
  spec.email         = ["support@mygrid.org.uk"]
  spec.summary       = "This library provides an API for manipulating "\
    "Research Object (RO) bundles."
  spec.description   = "This library provides an API for manipulating "\
    "Research Object (RO) bundles. The RO bundle specification can be found "\
    "at https://w3id.org/bundle/."
  spec.homepage      = "http://www.researchobject.org/"
  spec.license       = "BSD-3-Clause"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.extra_rdoc_files = [ "Changes.rdoc", "Licence.rdoc", "ReadMe.rdoc" ]
  spec.rdoc_options     = [ "-N", "--tab-width=2", "--main=ReadMe.rdoc" ]

  spec.required_ruby_version = ">= 2.6.0"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rdoc", "~> 6.3.1"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_development_dependency "coveralls", "~> 0.8.23"
  spec.add_runtime_dependency "ucf", "~> 2.0.2"
  spec.add_runtime_dependency "json", "~> 2.3.0"
  spec.add_runtime_dependency "uuid", "~> 2.3"
  spec.add_runtime_dependency "addressable", "~> 2.8.0"
end
