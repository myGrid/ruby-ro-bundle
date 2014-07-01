#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require "uuid"

module ROBundle

  # A class to represent an Annotation in a Research Object.
  class Annotation

    # :call-seq:
    #   new(about)
    #
    # Create a new Annotation with the specified "about" identifier.
    def initialize(object)
      if object.instance_of?(Hash)
        @structure = object
      else
        @structure = {}
        @structure[:about] = object
      end
    end

    # :call-seq:
    #   about
    #
    # The identifier for the annotated resource. This is considered the target
    # of the annotation, that is the resource the annotation content is
    # "somewhat about".
    def about
      @structure[:about]
    end

    # :call-seq:
    #   content
    #
    # The identifier for a resource that contains the body of the annotation.
    def content
      @structure[:content]
    end

    # :call-seq:
    #   annotation -> String
    #
    # Return the annotation id of this Annotation. An annotation id is a UUID
    # prefixed with "urn:uuid" as per
    # {RFC4122}[http://www.ietf.org/rfc/rfc4122.txt].
    #
    # If this Annotation has no annotation id a new one is generated and set
    # as the annotation id of this Annotation.
    def annotation
      @structure[:annotation] ||= UUID.generate(:urn)
    end

  end

end
