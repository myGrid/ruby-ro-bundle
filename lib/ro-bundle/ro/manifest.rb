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
    include Provenance

    FILE_NAME = "manifest.json" # :nodoc:
    DEFAULT_CONTEXT = "https://w3id.org/bundle/context" # :nodoc:
    DEFAULT_ID = "/" # :nodoc:

    # :call-seq:
    #   new
    #
    # Create a new managed file entry to represent the manifest.json file.
    def initialize
      super(FILE_NAME, :required => true)

      @structure = nil
      @initialized = false
      @edited = false
    end

    # :call-seq:
    #   initialized? -> true or false
    #
    # Has this manifest been initialized?
    def initialized?
      @initialized
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
    # as the identifier.
    def id
      structure[:id]
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
      structure[:aggregates]
    end

    # :call-seq:
    #   add_aggregate(entry) -> Aggregate
    #   add_aggregate(uri) -> Aggregate
    #
    # Add the given entry or URI to the list of aggregates in this manifest.
    # <tt>Errno:ENOENT</tt> is raised if the entry does not exist.
    #
    # The Aggregate object added to the Research Object is returned.
    def add_aggregate(entry)
      unless entry.instance_of?(Aggregate)
        unless Util.is_absolute_uri?(entry)
          raise Errno::ENOENT if container.find_entry(entry).nil?
        end

        entry = Aggregate.new(entry)
      end

      @edited = true
      structure[:aggregates] << entry
      entry
    end

    # :call-seq:
    #   remove_aggregate(filename)
    #   remove_aggregate(uri)
    #   remove_aggregate(Aggregate)
    #
    # Remove (unregister) an aggregate from this Research Object. If a
    # filename is supplied then the file is no longer aggregated, but it is
    # not deleted from the bundle by this method.
    #
    # Any annotations with the removed aggregate as their target are also
    # removed from the RO.
    def remove_aggregate(object)
      removed = nil

      if object.is_a?(Aggregate)
        removed = structure[:aggregates].delete(object)
        removed = removed.uri unless removed.nil?
      else
        removed = remove_aggregate_by_uri(object)
      end

      unless removed.nil?
        remove_annotation(removed)
        @edited = true
      end
    end

    # :call-seq:
    #   add_annotation(annotation) -> Annotation
    #   add_annotation(target, content = nil) -> Annotation
    #
    # Add an annotation to this Research Object. An annotation can either be
    # an already created annotation object, or a pair of values to build a new
    # annotation object explicitly.
    #
    # <tt>Errno:ENOENT</tt> is raised if the target of the annotation is not
    # an annotatable resource in this RO.
    #
    # The Annotation object added to the Research Object is returned.
    def add_annotation(object, content = nil)
      if object.instance_of?(Annotation)
        # If the supplied Annotation object is already registered then it is
        # the annotation itself we are annotating!
        if container.annotation?(object)
          object = Annotation.new(object.uri, content)
        end
      else
        object = Annotation.new(object, content)
      end

      target = object.target
      unless container.annotatable?(target)
        raise Errno::ENOENT,
          "'#{target}' is not a member of this Research Object or a URI."
      end

      @edited = true
      structure[:annotations] << object
      object
    end

    # :call-seq:
    #   remove_annotation(Annotation)
    #   remove_annotation(target)
    #   remove_annotation(id)
    #
    # Remove (unregister) annotations from this Research Object and return
    # them. Return +nil+ if the annotation does not exist.
    #
    # Any annotation content that is stored in the .ro/annotations directory
    # is automatically cleaned up when the RO is closed.
    def remove_annotation(object)
      if object.is_a?(Annotation)
        removed = [structure[:annotations].delete(object)].compact
      else
        removed = remove_annotation_by_field(object)
      end

      removed.each do |ann|
        id = ann.uri
        remove_annotation(id) unless id.nil?
      end

      @edited = true unless removed.empty?
    end

    # :call-seq:
    #   annotations
    #
    # Return a list of all the annotations in this Research Object.
    def annotations
      structure[:annotations]
    end

    # :call-seq:
    #   edited? -> true or false
    #
    # Has this manifest been altered in any way?
    def edited?
      if @structure.nil?
        @edited
      else
        @edited || edited(aggregates) || edited(annotations)
      end
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

    # The internal structure of this class cannot be setup at construction
    # time in the initializer as there is no route to its data on disk at that
    # point. Once loaded, parts of the structure are converted to local
    # objects where appropriate.
    def structure
      return @structure if initialized?
      @initialized = true

      begin
        struct ||= JSON.parse(contents, :symbolize_names => true)
      rescue Errno::ENOENT
        struct = {}
      end

      @structure = init_defaults(struct)
    end

    def init_defaults(struct)
      init_default_context(struct)
      init_default_id(struct)
      init_provenance_defaults(struct)
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

    def init_default_id(struct)
      id = struct[:id]
      if id.nil?
        @edited = true
        struct[:id] = DEFAULT_ID
      end

      struct
    end

    def remove_aggregate_by_uri(object)
      structure[:aggregates].each do |agg|
        if object == agg.uri || object == agg.file_entry
          return structure[:aggregates].delete(agg).uri
        end
      end

      # Return nil if nothing removed.
      nil
    end

    def remove_annotation_by_field(object)
      removed = []

      # Need to dup the list here so we don't break it when deleting things.
      # We can't use delete_if because we want to know what we've deleted!
      structure[:annotations].dup.each do |ann|
        if ann.uri == object ||
          ann.target == object ||
          ann.content == object

          removed << structure[:annotations].delete(ann)
        end
      end

      removed
    end

    def edited(resource)
      resource.each do |res|
        return true if res.edited?
      end

      false
    end

  end

end
