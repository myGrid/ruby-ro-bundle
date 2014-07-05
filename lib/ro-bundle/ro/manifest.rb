#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

#
module ROBundle

  # The manifest.json managed file entry for a Research Object.
  class Manifest < ZipContainer::ManagedFile

    FILE_NAME = "manifest.json" # :nodoc:
    DEFAULT_CONTEXT = "https://w3id.org/bundle/context" # :nodoc:

    # :call-seq:
    #   new
    #
    # Create a new managed file entry to represent the manifest.json file.
    def initialize
      super(FILE_NAME, :required => true)

      @edited = false
    end

    # :call-seq:
    #   context -> List of context URIs
    #
    # Return the list of @context URIs for this Research Object manifest.
    def context
      structure[:@context].dup
    end

    # :call-seq:
    #   add_context
    #
    # Add a URI to the front of the @context list.
    def add_context(uri)
      @edited = true
      structure[:@context].insert(0, uri.to_s)
    end

    # :call-seq:
    #   id -> String
    #
    # An RO identifier (usually '/') indicating the relative top-level folder
    # as the identifier. Returns +nil+ if the id is not present in the
    # manifest.
    def id
      structure.fetch(:id, "/")
    end

    # :call-seq:
    #   id = new_id
    #
    # Set the id of this Manifest.
    def id=(new_id)
      @edited = true
      structure[:id] = new_id
    end

    # :call-seq:
    #   created_on -> Time
    #
    # Return the time that this RO Bundle was created as a Time object, or
    # +nil+ if not present in the manifest.
    def created_on
      Util.parse_time(structure[:createdOn])
    end

    # :call-seq:
    #   created_on = new_time
    #
    # Set a new createdOn time for this Manifest. Anything that Ruby can
    # interpret as a time is accepted and converted to ISO8601 format on
    # serialization.
    def created_on=(new_time)
      @edited = true
      set_time(:createdOn, new_time)
    end

    # :call-seq:
    #   created_by -> Agent
    #
    # Return the Agent that created this Research Object.
    def created_by
      structure[:createdBy]
    end

    # :call-seq:
    #   created_by = Agent
    #
    # Set the Agent that has created this RO Bundle. Anything passed to this
    # method that is not an Agent will be ignored.
    def created_by=(new_creator)
      if new_creator.instance_of?(Agent)
        @edited = true
        structure[:createdBy] = new_creator
      end
    end

    # :call-seq:
    #   authored_on -> Time
    #
    # Return the time that this RO Bundle was edited as a Time object, or
    # +nil+ if not present in the manifest.
    def authored_on
      Util.parse_time(structure[:authoredOn])
    end

    # :call-seq:
    #   authored_on = new_time
    #
    # Set a new authoredOn time for this Manifest. Anything that Ruby can
    # interpret as a time is accepted and converted to ISO8601 format on
    # serialization.
    def authored_on=(new_time)
      @edited = true
      set_time(:authoredOn, new_time)
    end

    # :call-seq:
    #   authored_by -> Agents
    #
    # Return the list of Agents that authored this Research Object.
    def authored_by
      structure[:authoredBy].dup
    end

    # :call-seq:
    #   add_author(author)
    #
    # Add an author to the list of authors for this Research Object. The
    # supplied parameter can either be an Agent or the name of an author as a
    # String.
    def add_author(author)
      unless author.is_a?(Agent)
        author = Agent.new(author.to_s)
      end

      @edited = true
      structure[:authoredBy] << author
    end

    # :call-seq:
    #   history -> List of history entry names
    #
    # Return a list of filenames that hold provenance information for this
    # Research Object.
    def history
      structure[:history].dup
    end

    # :call-seq:
    #   add_history(entry)
    #
    # Add the given entry to the history list in this manifest.
    # <tt>Errno:ENOENT</tt> is raised if the entry does not exist.
    def add_history(entry)
      raise Errno::ENOENT if container.find_entry(entry).nil?

      # Mangle the filename according to the RO Bundle specification.
      name = entry_name(entry)
      dir = "#{@parent.full_name}/"
      name = name.start_with?(dir) ? name.sub(dir, "") : "/#{name}"

      @edited = true
      structure[:history] << name
    end

    # :call-seq:
    #   aggregates -> List of aggregated resources.
    #
    # Return a list of all the aggregated resources in this Research Object.
    def aggregates
      structure[:aggregates].dup
    end

    # :call-seq:
    #   add_aggregate(entry)
    #
    # Add the given entry to the list of aggregates in this manifest.
    # <tt>Errno:ENOENT</tt> is raised if the entry does not exist.
    def add_aggregate(entry)
      raise Errno::ENOENT if container.find_entry(entry).nil?

      # Mangle the filename according to the RO Bundle specification.
      name = "/#{entry_name(entry)}"

      @edited = true
      structure[:aggregates] << Aggregate.new(name)
    end

    # :call-seq:
    #   annotations
    #
    # Return a list of all the annotations in this Research Object.
    def annotations
      structure[:annotations].dup
    end

    # :call-seq:
    #   edited? -> true or false
    #
    # Has this manifest been altered in any way?
    def edited?
      @edited
    end

    # :call-seq:
    #   to_json(options = nil) -> String
    #
    # Write this Manifest out as a json string. Takes the same options as
    # JSON#generate.
    def to_json(*a)
      Util.clean_json(structure).to_json(*a)
    end

    protected

    # :call-seq:
    #   validate -> true or false
    #
    # Validate the correctness of the manifest file contents.
    def validate
      begin
        structure
      rescue JSON::ParserError, ROError
        return false
      end

      true
    end

    private

    def set_time(key, time)
      if time.instance_of?(String)
        time = Time.parse(time)
      end

      structure[key] = time.iso8601
    end

    # The internal structure of this class cannot be setup at construction
    # time in the initializer as there is no route to its data on disk at that
    # point. Once loaded, parts of the structure are converted to local
    # objects where appropriate.
    def structure
      return @structure if @structure

      begin
        struct ||= JSON.parse(contents, :symbolize_names => true)
      rescue Errno::ENOENT
        struct = {}
      end

      @structure = init_defaults(struct)
    end

    def init_defaults(struct)
      init_default_context(struct)
      creator = struct[:createdBy]
      struct[:createdBy] = Agent.new(creator) unless creator.nil?
      struct[:authoredBy] = [*struct.fetch(:authoredBy, [])].map do |agent|
        Agent.new(agent)
      end
      struct[:history] = [*struct.fetch(:history, [])]
      struct[:aggregates] = [*struct.fetch(:aggregates, [])].map do |agg|
        Aggregate.new(agg)
      end
      struct[:annotations] = [*struct.fetch(:annotations, [])].map do |ann|
        Annotation.new(ann)
      end

      struct
    end

    def init_default_context(struct)
      context = struct[:@context]
      if context.nil?
        @edited = true
        struct[:@context] = [ DEFAULT_CONTEXT ]
      else
        struct[:@context] = [*context]
      end

      struct
    end

  end

end
