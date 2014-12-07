#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

#
module ROBundle

  # This is the bass class of things which can appear in the manifest:
  # * Aggregate
  # * Annotation
  # * Proxy
  class ManifestEntry
    include Provenance

    # :call-seq:
    #   new
    #
    # Create a new ManifestEntry with an empty structure and the +edited+ flag
    # set to false.
    def initialize
      @structure = {}
      @edited = false
    end

    # :call-seq:
    #   edited? -> true or false
    #
    # Has this ManifestEntry been edited?
    def edited?
      @edited
    end

    # :stopdoc:
    # For internal use only!
    def stored
      @edited = false
    end
    # :startdoc:

    private

    def structure
      @structure
    end

  end

end
