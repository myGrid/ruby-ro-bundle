#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require "bundler/gem_tasks"
require "rake/testtask"
require "rdoc/task"

task :default => [:test]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/ts_ro_bundle.rb']
  t.verbose = true
end

RDoc::Task.new do |r|
  r.main = "ReadMe.rdoc"
  lib = Dir.glob("lib/**/*.rb")
  r.rdoc_files.include("ReadMe.rdoc", "Licence.rdoc", "Changes.rdoc", lib)
  r.options << "-t Research Object Bundle Ruby Library version " +
    "#{ROBundle::VERSION}"
  r.options << "-N"
  r.options << "--tab-width=2"
end
