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
    #   new(filename, mediatype = nil)
    #   new(URI)
    #
    # Create a new file or URI aggregate.
    def initialize(object, second = nil)
      @structure = {}

      if object.instance_of?(Hash)
        init_json(object)
      else
        init_file_or_uri(object)

        if @structure[:file]
          @structure[:mediatype] = second
        end
      end
    end

    # :call-seq:
    #   file
    #
    # The path of this aggregate. It should start with '/'.
    def file
      @structure[:file]
    end

    # :call-seq:
    #   file_entry
    #
    # The path of this aggregate in "rubyzip" format, i.e. no leading '/'.
    def file_entry
      Util.strip_leading_slash(file)
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
    # For a file aggregate, its
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
      init_file_or_uri(object[:file] || object[:uri])
      @structure = init_provenance_defaults(object)

      if @structure[:file]
        @structure[:mediatype] = object[:mediatype]
      end
    end

    def init_file_or_uri(object)
      if object.is_a?(String) && !Util.is_absolute_uri?(object)
        name = object.start_with?("/") ? object : "/#{object}"
        @structure[:file] = name
      elsif Util.is_absolute_uri?(object)
        @structure[:uri] = object.to_s
      else
        raise InvalidAggregateError.new(object)
      end
    end

  end

end