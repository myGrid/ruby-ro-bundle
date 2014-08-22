#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

#
module ROBundle

  # The base of all exceptions raised by this library.
  class ROError < RuntimeError
  end

  # This exception is raised when an invalid aggregate is detected.
  class InvalidAggregateError < ROError

    # :call-seq:
    #   new(name)
    #
    # Create a new InvalidAggregateError with the invalid object (file or
    # URI) supplied.
    def initialize(object)
      super("'#{object}' is not an absolute filename or a URI.")
    end

  end

end
