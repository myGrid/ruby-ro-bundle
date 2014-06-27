#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

module ROBundle
  class RODir < ZipContainer::ManagedDirectory

    DIR_NAME = ".ro"

    def initialize(manifest)
      super(DIR_NAME, :required => false, :entries => manifest)
    end
  end

  class Manifest < ZipContainer::ManagedFile

    FILE_NAME = "manifest.json"

    def initialize
      super(FILE_NAME, :required => false)
    end

    # Need this because we can't access file contents in the constructor.
    def structure
      begin
        @structure ||= JSON.parse(contents)
      rescue
        @structure = {}
      end
    end

  end
end
