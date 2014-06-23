#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

module ROBundle
  class RODir < ZipContainer::ManagedDirectory
    def initialize
      super(".ro", false, [Manifest.new])
    end
  end

  class Manifest < ZipContainer::ManagedFile
    def initialize
      super("manifest.json", false)
    end
  end
end
