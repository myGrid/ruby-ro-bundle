#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

#
module ROBundle

  # A class to represent an agent in a Research Object. An agent can be, for
  # example, a person or software.
  class Agent

    # :call-seq:
    #   new(name, uri = nil, orcid = nil)
    #
    # Create a new Agent with the supplied details. If +uri+ or +orcid+ are
    # not absolute URIs then they are set to +nil+.
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
        :uri => Util.is_absolute_uri?(uri) ? uri.to_s : nil,
        :orcid => Util.is_absolute_uri?(orcid) ? orcid.to_s : nil
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
    #   to_json(options = nil) -> String
    #
    # Write this Agent out as a json string. Takes the same options as
    # JSON#generate.
    def to_json(*a)
      Util.clean_json(@structure).to_json(*a)
    end

  end

end
