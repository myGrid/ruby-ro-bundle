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
      super(DIR_NAME, :required => true, :entries => manifest)
    end
  end

end
