#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

module ROBundle

  class Manifest < ZipContainer::ManagedFile

    FILE_NAME = "manifest.json"

    def initialize
      super(FILE_NAME, :required => true)
    end

    # Need this because we can't access file contents in the constructor.
    def structure
      begin
        @structure ||= JSON.parse(contents)
      rescue Errno::ENOENT
        @structure = {}
      end
    end

    protected

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
