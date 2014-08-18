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
      @manifest = manifest
      @annotations_directory = AnnotationsDir.new

      super(DIR_NAME, :required => true,
        :entries => [@manifest, @annotations_directory])
    end

    # The managed annotations directory within the .ro directory.
    class AnnotationsDir < ZipContainer::ManagedDirectory

      DIR_NAME = "annotations" # :nodoc:

      # :call-seq:
      #   new
      #
      # Create a new annotations managed directory. The directory is hidden
      # under normal circumstances.
      def initialize
        super(DIR_NAME, :hidden => true)
      end

    end
  end
end
