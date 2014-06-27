#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
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
  spec.authors       = ["Robert Haines"]
  spec.email         = ["support@mygrid.org.uk"]
  spec.summary       = "This library provides an API for manipulating "\
    "Research Object (RO) bundles."
  spec.description   = "This library provides an API for manipulating "\
    "Research Object (RO) bundles. The RO bundle specification can be found "\
    "at http://purl.org/wf4ever/ro-bundle."
  spec.homepage      = "http://www.taverna.org.uk"
  spec.license       = "BSD"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.has_rdoc         = true
  spec.extra_rdoc_files = [ "Changes.rdoc", "Licence.rdoc", "ReadMe.rdoc" ]
  spec.rdoc_options     = [ "-N", "--tab-width=2", "--main=ReadMe.rdoc" ]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency("rdoc", "~> 4.1")
  spec.add_development_dependency "coveralls"
  #spec.add_runtime_dependency "ucf", "~> 0.7"
  spec.add_runtime_dependency "json", "~> 1.8"
end
