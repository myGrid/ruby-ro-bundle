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

    # :call-seq:
    #   new(filename)
    #   new(URI)
    #
    # Create a new file or URI aggregate.
    def initialize(object)
      @structure = {}

      if object.instance_of?(Hash)
        init_json(object)
      else
        init_file_or_uri(object)
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
    #   created_on
    #
    # The time that this resource was created.
    def created_on
      Util.parse_time(@structure[:createdOn])
    end

    # :call-seq:
    #   created_by
    #
    # The Agent which created this aggregated resource.
    def created_by
      @structure[:createdBy]
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

    def init_json(object)
      init_file_or_uri(object[:file] || object[:uri])

      if @structure[:file]
        @structure[:mediatype] = object[:mediatype]
        @structure[:createdOn] = object[:createdOn]
        @structure[:createdBy] = Agent.new(object.fetch(:createdBy, {}))
      end
    end

    def init_file_or_uri(object)
      if object.is_a?(String) && object.start_with?("/")
        return @structure[:file] = object
      end

      invalid = false
      begin
        uri = Util.parse_uri(object)
      rescue URI::InvalidURIError
        invalid = true
      end

      if uri.nil? || invalid || uri.scheme.nil?
        raise InvalidAggregateError.new(object)
      end

      @structure[:uri] = uri
    end

  end

end
