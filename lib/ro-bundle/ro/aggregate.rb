#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require "time"
require "uri"

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
      @structure[:created_on]
    end

    # :call-seq:
    #   created_by
    #
    # The Agent which created this aggregated resource.
    def created_by
      @structure[:created_by]
    end

    private

    def init_json(object)
      init_file_or_uri(object[:file] || object[:uri])

      if @structure[:file]
        @structure[:mediatype] = object[:mediatype]
        @structure[:created_on] = parse_time(object.fetch(:createdOn, ""))
        @structure[:created_by] = Agent.new(object.fetch(:createdBy, {}))
      end
    end

    def init_file_or_uri(object)
      return @structure[:uri] = object if object.is_a?(URI)
      return @structure[:file] = object if object.is_a?(String) && object.start_with?("/")

      invalid = false
      begin
        @structure[:uri] = URI.parse(object)
      rescue URI::InvalidURIError
        invalid = true
      end

      raise InvalidAggregateError.new(object) if invalid || @structure[:uri].scheme.nil?
    end

    def parse_time(time)
      return if time.empty?
      Time.parse(time)
    end

  end

end
