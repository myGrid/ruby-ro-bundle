#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

#
module ROBundle

  # This class represents a Research Object Bundle file. See the
  # {RO Bundle specification}[https://w3id.org/bundle/] for more details.
  #
  # Many of the methods that this class provides are actually implemented in
  # the Manifest class, so please see its documentation for details.
  class File < UCF::File

    extend Forwardable
    def_delegators :@manifest, :add_author, :aggregates, :annotations,
                   :authored_by, :authored_on, :authored_on=, :created_by,
                   :created_by=, :created_on, :created_on=, :history, :id,
                   :id=, :remove_annotation, :remove_author, :retrieved_by,
                   :retrieved_by=, :retrieved_from, :retrieved_from=,
                   :retrieved_on, :retrieved_on=

    private_class_method :new

    attr_reader :manifest

    # :stopdoc:
    MIMETYPE = "application/vnd.wf4ever.robundle+zip"

    def initialize(filename)
      super(filename)

      # Initialize the managed entries and register the .ro directory.
      @manifest = Manifest.new
      @ro_dir = RODir.new(@manifest)
      initialize_managed_entries(@ro_dir)
    end
    # :startdoc:

    # :call-seq:
    #   create(filename) -> File
    #   create(filename, mimetype) -> File
    #   create(filename) {|file| ...}
    #   create(filename, mimetype) {|file| ...}
    #
    # Create a new RO Bundle file on disk and open it for editing. A custom
    # mimetype for the bundle may be specified but is unnecessary if the
    # default, "application/vnd.wf4ever.robundle+zip", will be used.
    #
    # Please see the
    # {UCF documentation}[http://mygrid.github.io/ruby-ucf/]
    # for much more information and a list of all the other methods available
    # in this class. RDoc does not list inherited methods, unfortunately.
    def self.create(filename, mimetype = MIMETYPE, &block)
      # Wow. I have to specifically send nil as the block to stop super from
      # sending the other block up automatically. Is this a bug in Ruby?
      ro = super(filename, mimetype, &nil)
      ro.init_metadata

      if block_given?
        begin
          yield ro
        ensure
          ro.close
        end
      end

      ro
    end

    # :call-seq:
    #   add(entry, src_path, options = {}, &continue_on_exists_proc) -> Aggregate or nil
    #
    # Convenience method for adding the contents of a file to the bundle
    # file. If asked to add a file with a reserved name, such as the special
    # mimetype header file or .ro/manifest.json, this method will raise a
    # ReservedNameClashError.
    #
    # This method automatically adds new entries to the list of bundle
    # aggregates unless the <tt>:aggregate</tt> option is set to false.
    #
    # If the added entry is aggregated then the Aggregate object is returned,
    # otherwise +nil+ is returned.
    #
    # See the rubyzip documentation for details of the
    # +continue_on_exists_proc+ parameter.
    def add(entry, src_path, options = {}, &continue_on_exists_proc)
      super(entry, src_path, &continue_on_exists_proc)

      options = { :aggregate => true }.merge(options)

      if options[:aggregate]
        @manifest.add_aggregate(entry)
      end
    end

    # :call-seq:
    #   add_aggregate(uri) -> Aggregate
    #   add_aggregate(entry) -> Aggregate
    #   add_aggregate(entry, src_path, &continue_on_exists_proc) -> Aggregate
    #
    # The first form of this method adds a URI as an aggregate of the bundle.
    #
    # The second form adds an already existing entry in the bundle to the list
    # of aggregates. <tt>Errno:ENOENT</tt> is raised if the entry does not
    # exist.
    #
    # The third form is equivalent to File#add called without any options.
    #
    # In all cases the Aggregate object added to the Research Object is
    # returned.
    def add_aggregate(entry, src_path = nil, &continue_on_exists_proc)
      if src_path.nil?
        @manifest.add_aggregate(entry)
      else
        add(entry, src_path, &continue_on_exists_proc)
      end
    end

    # :call-seq:
    #   add_annotation(annotation_object) -> Annotation
    #   add_annotation(aggregate, content, options = {}) -> Annotation
    #   add_annotation(aggregate, file, options = {}) -> Annotation
    #   add_annotation(aggregate, uri, options = {}) -> Annotation
    #   add_annotation(uri, content, options = {}) -> Annotation
    #   add_annotation(uri, file, options = {}) -> Annotation
    #   add_annotation(uri, uri, options = {}) -> Annotation
    #   add_annotation(annotation, content, options = {}) -> Annotation
    #   add_annotation(annotation, file, options = {}) -> Annotation
    #   add_annotation(annotation, uri, options = {}) -> Annotation
    #
    # This method has two forms.
    #
    # The first form registers an already initialized Annotation object in
    # this Research Object.
    #
    # The second form creates a new Annotation object for the specified target
    # with the specified (or empty content) and registers it in this Research
    # Object.
    #
    # In both cases <tt>Errno:ENOENT</tt> is raised if the target of the
    # annotation is not an annotatable resource.
    #
    # The Annotation object added to the Research Object is returned.
    def add_annotation(target, body = nil, options = {})
      options = { :aggregate => false }.merge(options)

      if target.is_a?(Annotation) || annotatable?(target)
        if body.nil? || aggregate?(body)
          content = body
        elsif Util.is_absolute_uri?(body)
          content = body
          @manifest.add_aggregate(body) if options[:aggregate]
        else
          content = @ro_dir.write_annotation_data(body, options)
        end

        @manifest.add_annotation(target, content)
      else
        raise Errno::ENOENT,
          "'#{target}' is not a member of this Research Object or a URI."
      end
    end

    # :call-seq:
    #   add_history(entry)
    #   add_history(entry, src_path, &continue_on_exists_proc)
    #
    # The first form of this method adds an already existing entry in the
    # bundle to the history list in the manifest. <tt>Errno:ENOENT</tt> is
    # raised if the entry does not exist.
    #
    # The second form adds the entry before adding it to the history list. The
    # entry is not aggregated.
    def add_history(entry, src_path = nil, &continue_on_exists_proc)
      unless src_path.nil?
        add(entry, src_path, :aggregate => false, &continue_on_exists_proc)
      end

      @manifest.add_history(entry)
    end

    # :call-seq:
    #   aggregate?(uri) -> true or false
    #   aggregate?(entry) -> true or false
    #
    # Is the supplied URI or entry aggregated in this Research Object?
    def aggregate?(entry)
      return true if entry == @manifest.id

      if Util.is_absolute_uri?(entry)
        entry = entry.to_s
      else
        entry = entry_name(entry)
      end

      aggregates.each do |agg|
        return true if agg.uri == entry || agg.file_entry == entry
      end

      false
    end

    # :call-seq:
    #   annotatable?(target) -> true or false
    #
    # Is the supplied target an annotatable resource? An annotatable resource
    # is either an absolute URI (which may or may not be aggregated in the
    # RO), an aggregated resource or another registered annotation.
    def annotatable?(target)
      Util.is_absolute_uri?(target) || annotation?(target) || aggregate?(target)
    end

    # :call-seq:
    #   annotation?(id) -> true or false
    #   annotation?(annotation) -> true or false
    #
    # Is the supplied id or annotation registered in this Research Object?
    def annotation?(id)
      id = id.uri if id.instance_of?(Annotation)

      annotations.each do |ann|
        return true if ann.uri == id
      end

      false
    end

    # :call-seq:
    #   commit -> true or false
    #   close -> true or false
    #
    # Commits changes that have been made since the previous commit to the
    # RO Bundle file. Returns +true+ if anything was actually done, +false+
    # otherwise.
    def commit
      if @manifest.edited?
        # This will overwrite the old version.
        @manifest.write

        @ro_dir.cleanup_annotation_data
      end

      super
    end

    alias :close :commit

    # :call-seq:
    #   commit_required? -> true or false
    #
    # Returns +true+ if any changes have been made to this RO Bundle file
    # since the last commit, +false+ otherwise.
    def commit_required?
      super || @manifest.edited?
    end

    # :call-seq:
    #   find_entry(entry_name, options = {}) -> Zip::Entry or nil
    #
    # Searches for the entry with the specified name. Returns +nil+ if no
    # entry is found or if the specified entry is hidden for normal use. You
    # can specify <tt>:include_hidden => true</tt> to include hidden entries
    # in the search.
    def find_entry(entry_name, options = {})
      return if Util.is_absolute_uri?(entry_name)

      super(entry_name, options)
    end

    # :call-seq:
    #   remove(entry)
    #
    # Removes the specified entry from the Research Object bundle. If asked to
    # remove any reserved files such as the special mimetype header file this
    # method will do nothing.
    #
    # If the entry being removed is aggregated in this RO then the aggregation
    # is removed. All annotations that refer to the removed entry are also
    # removed.
    def remove(entry, preserve_manifest = false)
      super(entry)

      # The preserve manifest flag is STRICTLY for internal use only.
      unless preserve_manifest
        name = entry_name(entry)
        @manifest.remove_aggregate("/#{name}")
        remove_annotation("/#{name}")
      end
    end

    # :call-seq:
    #   remove_aggregate(entry)
    #   remove_aggregate(uri)
    #   remove_aggregate(Aggregate)
    #
    # Remove (unregister) an aggregate from this Research Object. If it is a
    # file then the file is no longer aggregated, and it is deleted from the
    # bundle by this method unless the option <tt>:keep_file => true</tt> is
    # supplied.
    #
    # Any annotations with the removed aggregate as their target are also
    # removed from the RO.
    def remove_aggregate(object, options = {})
      options = { :keep_file => false }.merge(options)
      file = nil

      if object.is_a?(Aggregate)
        file = object.file_entry
      elsif !Util.is_absolute_uri?(object)
        object = entry_name(object)
        file = Util.strip_leading_slash(object)
      end

      if !file.nil? && !options[:keep_file]
        remove(file, true)
      end

      @manifest.remove_aggregate(object)
    end

    # :stopdoc:
    def init_metadata
      mkdir(@ro_dir.full_name)
      @manifest.init
      commit
    end
    # :startdoc:

  end
end
