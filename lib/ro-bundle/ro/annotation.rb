#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

#
module ROBundle

  # A class to represent an Annotation in a Research Object.
  class Annotation < ManifestEntry

    # :call-seq:
    #   new(target, content = nil)
    #
    # Create a new Annotation with the specified "about" identifier. A new
    # annotation ID is generated and set for the new annotation. The +content+
    # parameter can be optionally used to set the file or URI that holds the
    # body of the annotation.
    #
    # An annotation id is a UUID prefixed with "urn:uuid" as per
    # {RFC4122}[http://www.ietf.org/rfc/rfc4122.txt].
    def initialize(object, content = nil)
      super()

      if object.instance_of?(Hash)
        @structure = object
        init_provenance_defaults(@structure)
      else
        @structure = {}
        @structure[:about] = object
        @structure[:uri] = UUID.generate(:urn)
        @structure[:content] = content
      end
    end

    # :call-seq:
    #   target
    #
    # The identifier for the annotated resource. This is considered the target
    # of the annotation, that is the resource the annotation content is
    # "somewhat about".
    def target
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
    #   content = new_content
    #
    # Set the content of this annotation.
    def content=(new_content)
      @edited = true
      @structure[:content] = new_content
    end

    # :call-seq:
    #   uri -> String in the form of a urn:uuid URI.
    #
    # Return the annotation id of this Annotation.
    def uri
      @structure[:uri]
    end

    # :call-seq:
    #   to_json(options = nil) -> String
    #
    # Write this Annotation out as a json string. Takes the same options as
    # JSON#generate.
    def to_json(*a)
      Util.clean_json(@structure).to_json(*a)
    end

  end

end