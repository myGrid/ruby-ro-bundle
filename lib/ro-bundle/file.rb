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
    def_delegators :@manifest, :aggregates, :annotations, :authored_by,
      :authored_on, :authored_on=, :created_by, :created_by=, :created_on,
      :created_on=, :history, :id, :id=

    private_class_method :new

    # :stopdoc:
    MIMETYPE = "application/vnd.wf4ever.robundle+zip"

    def initialize(filename)
      super(filename)

      # Initialize the managed entries and register the .ro directory.
      @manifest = Manifest.new
      initialize_managed_entries(RODir.new(@manifest))
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

  end
end
