#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require "forwardable"

module ROBundle

  # This class represents a Research Object Bundle file. See the
  # {RO Bundle specification}[http://wf4ever.github.io/ro/bundle/]
  # for more details.
  #
  # Many of the methods that this class provides are actually implemented in
  # the Manifest class, so please see its documentation for details.
  class File < UCF::File

    extend Forwardable
    def_delegators :@manifest, :add_author, :aggregates, :annotations,
      :authored_by, :authored_on, :authored_on=, :created_by, :created_by=,
      :created_on, :created_on=, :history, :id, :id=

    private_class_method :new

    # :stopdoc:
    MIMETYPE = "application/vnd.wf4ever.robundle+zip"

    def initialize(filename)
      super(filename)

      # Initialize the managed entries and register the .ro directory.
      @manifest = Manifest.new
      @ro_dir = RODir.new(@manifest)
      initialize_managed_entries(@ro_dir)

      # Create the .ro directory if it does not already exist.
      if find_entry(@ro_dir.full_name).nil?
        mkdir(@ro_dir.full_name)
        commit
      end
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
      super(filename, mimetype, &block)
    end

    # :call-seq:
    #   add(entry, src_path, options = {}, &continue_on_exists_proc)
    #
    # Convenience method for adding the contents of a file to the bundle
    # file. If asked to add a file with a reserved name, such as the special
    # mimetype header file or .ro/manifest.json, this method will raise a
    # ReservedNameClashError.
    #
    # This method automatically adds new entries to the list of bundle
    # aggregates unless the <tt>:aggregate</tt> option is set to false.
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
    #   add_aggregate(uri)
    #   add_aggregate(entry)
    #   add_aggregate(entry, src_path, &continue_on_exists_proc)
    #
    # The first form of this method adds a URI as an aggregate of the bundle.
    #
    # The second form adds an already existing entry in the bundle to the list
    # of aggregates. <tt>Errno:ENOENT</tt> is raised if the entry does not
    # exist.
    #
    # The third form is equivalent to File#add called without any options.
    def add_aggregate(entry, src_path = nil, &continue_on_exists_proc)
      if src_path.nil?
        @manifest.add_aggregate(entry)
      else
        add(entry, src_path, &continue_on_exists_proc)
      end
    end

    # :call-seq:
    #   add_history(entry, &continue_on_exists_proc)
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
        entry = Util.parse_uri(entry)
      else
        entry = entry_name(entry)
        entry = entry.start_with?("/") ? entry : "/#{entry}"
      end

      aggregates.each do |agg|
        return true if agg.uri == entry || agg.file == entry
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
        name = @manifest.full_name
        remove(name) unless find_entry(name).nil?

        file.open(name, "w") do |m|
          m.puts JSON.pretty_generate(@manifest)
        end
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
  end
end
