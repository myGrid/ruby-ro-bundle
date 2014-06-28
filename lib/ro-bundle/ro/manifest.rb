#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require "time"

module ROBundle

  # The manifest.json managed file entry for a Research Object.
  class Manifest < ZipContainer::ManagedFile

    # :nodoc:
    FILE_NAME = "manifest.json"

    # :call-seq:
    #   new
    #
    # Create a new managed file entry to represent the manifest.json file.
    def initialize
      super(FILE_NAME, :required => true)
    end

    # :call-seq:
    #   id -> String
    #
    # An RO identifier (usually '/') indicating the relative top-level folder
    # as the identifier. Returns +nil+ if the id is not present in the
    # manifest.
    def id
      structure.fetch("id", nil)
    end

    # :call-seq:
    #   created_on -> Time
    #
    # Return the time that this RO Bundle was created as a Time object, or
    # +nil+ if not present in the manifest.
    def created_on
      parse_time(:createdOn)
    end

    # :call-seq:
    #   created_by -> Agent
    #
    # Return the Agent that created this Research Object.
    def created_by
      @created_by ||= Agent.new(structure.fetch("createdBy", {}))
    end

    # :call-seq:
    #   authored_on -> Time
    #
    # Return the time that this RO Bundle was edited as a Time object, or
    # +nil+ if not present in the manifest.
    def authored_on
      parse_time(:authoredOn)
    end

    # :call-seq:
    #   authored_by -> Agents
    #
    # Return the list of Agents that authored this Research Object.
    def authored_by
      @authored_by ||= structure.fetch("authoredBy", []).map do |agent|
        Agent.new(agent)
      end
    end

    protected

    # :call-seq:
    #   structure -> Hash
    #
    # Returns the structure of the manifest json as a hash.
    def structure
      begin
        @structure ||= JSON.parse(contents)
      rescue Errno::ENOENT
        @structure = {}
      end
    end

    # :call-seq:
    #   validate -> true or false
    #
    # Validate the correctness of the manifest file contents.
    def validate
      begin
        structure
      rescue JSON::ParserError
        return false
      end

      true
    end

    private

    def parse_time(key)
      time = structure.fetch(key.to_s, "")
      return if time.empty?

      Time.parse(time)
    end

  end

end
