#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require "bundler/setup"
require "json"
require "ucf"

require "ro-bundle/version"
require "ro-bundle/ro/agent"
require "ro-bundle/ro/manifest"
require "ro-bundle/ro/directory"
require "ro-bundle/file"

# This is a ruby library to read and write Research Object Bundle files in PK
# Zip format. See the ROBundle::File class for more information.
#
# See
# {the RO Bundle specification}[http://wf4ever.github.io/ro/bundle/]
# for more details.
#
# Most of this library's API is provided by two underlying gems. Please
# consult their documentation in addition to this:
#
# * {zip-container gem}[https://rubygems.org/gems/zip-container]
#   {documentation}[http://mygrid.github.io/ruby-zip-container/]
# * {ucf gem}[https://rubygems.org/gems/ucf]
#   {documentation}[http://mygrid.github.io/ruby-ucf]
#
# There are code examples available with the source code of this library.
module ROBundle
end
