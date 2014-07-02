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

  # A module with lots of utility functions.
  module Util

    # :call-seq:
    #   clean_json(json_hash) -> Hash
    #
    # Remove empty strings and nils from a json hash structure.
    def self.clean_json(structure)
      structure.delete_if do |_, v|
        v.nil? || (v.respond_to?(:empty?) && v.empty?)
      end
    end

    # :call-seq:
    #   parse_time(time) -> Time
    #
    # Parse a time string into a Time object. Does not try to parse +nil+.
    def self.parse_time(time)
      return if time.nil?
      Time.parse(time)
    end

    # :call-seq:
    #   parse_uri(uri) -> URI
    #
    # Parse a string into a URI. Does not try to parse something that is
    # already a URI, or +nil+.
    def self.parse_uri(uri)
      return uri if uri.nil? || uri.is_a?(URI)
      URI.parse(uri)
    end

  end

end
