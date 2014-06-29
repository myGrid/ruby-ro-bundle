#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'coveralls'
Coveralls.wear!

# Example data files
$hello = "test/data/HelloAnyone.robundle"

require "tc_agent"
require "tc_aggregate"
require "tc_manifest"
require "tc_read"
require "tc_create"
