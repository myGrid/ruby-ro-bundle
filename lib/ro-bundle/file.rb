#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

module ROBundle
  class File < UCF::Container

    private_class_method :new

    # :stopdoc:
    MIMETYPE = "application/vnd.wf4ever.robundle+zip"

    def initialize(filename)
      super(filename)

      # Initialize the managed entries and register the .ro directory.
      initialize_managed_entries(RODir.new)
    end
    # :startdoc:

    def File.create(filename, mimetype = MIMETYPE, &block)
      super(filename, mimetype, &block)
    end
  end
end
