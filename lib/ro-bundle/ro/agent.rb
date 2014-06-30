#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require "uri"

module ROBundle

  # A class to represent an agent in a Research Object. An agent can be, for
  # example, a person or software.
  class Agent

    # The name of this agent.
    attr_reader :name

    # A URI identifying the agent. This should be a
    # {WebID}[http://www.w3.org/wiki/WebID].
    attr_reader :uri

    # An ORCID identifier for this agent.
    attr_reader :orcid

    # :call-seq:
    #   new(name, uri = nil, orcid = nil)
    #
    # Create a new Agent with the supplied details.
    def initialize(first, uri = nil, orcid = nil)
      if first.instance_of?(Hash)
        @name = first["name"] || ""
        @uri = parse_uri(first["uri"])
        @orcid = parse_uri(first["orcid"])
      else
        @name = first
        @uri = parse_uri(uri)
        @orcid = parse_uri(orcid)
      end
    end

    # :call-seq:
    #   to_json -> String
    #   to_json(:compact) -> String
    #
    # Write this Agent out as a json string. The default is to produce a human
    # readable indented format; the compact version is as compressed as
    # possible on a single line.
    def to_json(format = false)
      hash = { "uri" => uri, "orcid" => orcid, "name" => name }

      if format == :compact
        JSON.generate hash
      else
        JSON.pretty_generate hash
      end
    end

    private

    def parse_uri(uri)
      return uri if uri.nil? || uri.is_a?(URI)

      URI.parse(uri)
    end
  end

end
