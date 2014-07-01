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

    # :call-seq:
    #   new(name, uri = nil, orcid = nil)
    #
    # Create a new Agent with the supplied details.
    def initialize(first, uri = nil, orcid = nil)
      if first.instance_of?(Hash)
        name = first[:name]
        uri = first[:uri]
        orcid = first[:orcid]
      else
        name = first
      end

      @structure = {
        :name => name,
        :uri => parse_uri(uri),
        :orcid => parse_uri(orcid)
      }
    end

    # :call-seq:
    #   name -> string
    #
    # The name of this agent.
    def name
      @structure[:name]
    end

    # :call-seq:
    #   uri -> URI
    #
    # A URI identifying the agent. This should, if it exists, be a
    # {WebID}[http://www.w3.org/wiki/WebID].
    def uri
      @structure[:uri]
    end

    # :call-seq:
    #   orcid -> URI
    #
    # An ORCID identifier URI for this agent.
    def orcid
      @structure[:orcid]
    end

    # :call-seq:
    #   to_json -> String
    #   to_json(:compact) -> String
    #
    # Write this Agent out as a json string. The default is to produce a human
    # readable indented format; the compact version is as compressed as
    # possible on a single line.
    def to_json(format = false)
      if format == :compact
        JSON.generate @structure
      else
        JSON.pretty_generate @structure
      end
    end

    private

    def parse_uri(uri)
      return uri if uri.nil? || uri.is_a?(URI)

      URI.parse(uri)
    end
  end

end
