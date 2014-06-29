#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

#
module ROBundle

  # The managed .ro directory entry of a Research Object.
  class RODir < ZipContainer::ManagedDirectory

    DIR_NAME = ".ro" # :nodoc:

    # :call-seq:
    #   new(manifest)
    #
    # Create a new .ro managed directory entry with the specified manifest
    # file object.
    def initialize(manifest)
      super(DIR_NAME, :required => true, :entries => manifest)
    end
  end

end
