#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require "time"

#
module ROBundle

  # A module with lots of utility functions. Most (maybe all) are private.
  module Util

    # :call-seq:
    #   parse_time(time) -> Time
    #
    # Parse a time string into a Time object. Does not try to parse +nil+.
    def self.parse_time(time)
      return if time.nil?
      Time.parse(time)
    end

  end

end
