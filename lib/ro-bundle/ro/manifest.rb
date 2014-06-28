#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

#
module ROBundle

  # The manifest.json managed file entry for a Research Object.
  class Manifest < ZipContainer::ManagedFile

    # :nodoc:
    FILE_NAME = "manifest.json"

    # :call-seq:
    #   new
    #
    # Create a new managed file entry to represent the manifest.json file.
    def initialize
      super(FILE_NAME, :required => true)
    end

    # :call-seq:
    #   structure -> Hash
    #
    # Returns the structure of the manifest json as a hash.
    def structure
      begin
        @structure ||= JSON.parse(contents)
      rescue Errno::ENOENT
        @structure = {}
      end
    end

    protected

    # :call-seq:
    #   validate -> true or false
    #
    # Validate the correctness of the manifest file contents.
    def validate
      begin
        structure
      rescue JSON::ParserError
        return false
      end

      true
    end

  end

end
