#------------------------------------------------------------------------------
# Copyright (c) 2014, 2015 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'coveralls'
Coveralls.wear!

# Example data files
$hello = "test/data/HelloAnyone.robundle"
$invalid = "test/data/invalid-manifest.robundle"
$man_ex3 = "test/data/example3-manifest.json"
$man_ex6 = "test/data/example6-manifest.json"
$man_empty = "test/data/empty-manifest.json"
$man_invalid = "test/data/invalid-manifest.json"

require "tc_util"
require "tc_agent"
require "tc_provenance"
require "tc_annotation"
require "tc_proxy"
require "tc_aggregate"
require "tc_manifest"
require "tc_read"
require "tc_create"
require "tc_add_annotation"
require "tc_remove"
