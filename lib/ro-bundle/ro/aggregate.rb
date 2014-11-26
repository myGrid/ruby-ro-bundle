#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

#
module ROBundle

  # A class to represent an aggregated resource in a Research Object. It holds
  # standard meta-data for either file or URI resources. An aggregate can only
  # represent a file OR a URI resource, not both at once.
  class Aggregate
    include Provenance

    # :call-seq:
    #   new(uri, mediatype)
    #   new(uri)
    #
    # Create a new file or URI aggregate.
    def initialize(object, mediatype = nil)
      @structure = {}

      if object.instance_of?(Hash)
        init_json(object)
      else
        @structure[:uri] = if Util.is_absolute_uri?(object)
                             object.to_s
                           else
                             object.start_with?("/") ? object : "/#{object}"
                           end
        @structure[:mediatype] = mediatype
      end
    end

    # :call-seq:
    #   file_entry
    #
    # The path of this aggregate in "rubyzip" format, i.e. no leading '/'.
    def file_entry
      Util.strip_leading_slash(uri) unless Util.is_absolute_uri?(uri)
    end

    # :call-seq:
    #   uri
    #
    # The URI of this aggregate. It should be an absolute URI.
    def uri
      @structure[:uri]
    end

    # :call-seq:
    #   mediatype
    #
    # This aggregate's
    # {IANA media type}[http://www.iana.org/assignments/media-types].
    def mediatype
      @structure[:mediatype]
    end

    # :call-seq:
    #   to_json(options = nil) -> String
    #
    # Write this Aggregate out as a json string. Takes the same options as
    # JSON#generate.
    def to_json(*a)
      Util.clean_json(@structure).to_json(*a)
    end

    private

    def structure
      @structure
    end

    def init_json(object)
      @structure = init_provenance_defaults(object)
      @structure[:uri] = object[:uri]
      @structure[:mediatype] = object[:mediatype]
    end

  end

end
