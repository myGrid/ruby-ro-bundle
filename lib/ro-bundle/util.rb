#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

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
    #   is_absolute_uri?(uri) -> true or false
    #
    # Is the supplied URI absolute? An absolute URI is a valid URI that starts
    # with a scheme, such as http, https or urn.
    def self.is_absolute_uri?(uri)
      uri = URI.parse(uri) unless uri.is_a?(URI)
      !uri.scheme.nil?
    rescue URI::InvalidURIError
      false
    end

  end

end
