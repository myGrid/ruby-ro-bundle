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

    # The path of this aggregate. It should start with '/'.
    attr_reader :file

    # The URI of this aggregate. It should be an absolute URI.
    attr_reader :uri

    # For a file aggregate,
    # its {IANA media type}[http://www.iana.org/assignments/media-types].
    attr_reader :mediatype

    # The time that this resource was created.
    attr_reader :created_on

    # The Agent which created this aggregated resource.
    attr_reader :created_by

    # :call-seq:
    #   new(filename)
    #   new(URI)
    #
    # Create a new file or URI aggregate.
    def initialize(object)
      if object.instance_of?(Hash)
        init_json(object)
      else
        init_file_or_uri(object)
      end
    end

    private

    def init_json(object)
      init_file_or_uri(object["file"] || object["uri"])

      if @file
        @mediatype = object["mediatype"]
        @created_on = parse_time(object.fetch("createdOn", ""))
        @created_by = Agent.new(object.fetch("createdBy", {}))
      end
    end

    def init_file_or_uri(object)
      return @uri = object if object.is_a?(URI)
      return @file = object if object.is_a?(String) && object.start_with?("/")

      invalid = false
      begin
        @uri = URI.parse(object)
      rescue URI::InvalidURIError
        invalid = true
      end

      raise InvalidAggregateError.new(object) if invalid || @uri.scheme.nil?
    end

    def parse_time(time)
      return if time.empty?
      Time.parse(time)
    end

  end

end
