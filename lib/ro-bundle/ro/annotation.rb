#------------------------------------------------------------------------------
# Copyright (c) 2014, 2015 The University of Manchester, UK.
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
        @structure[:about] = [*@structure[:about]]
        init_provenance_defaults(@structure)
      else
        @structure = {}
        @structure[:about] = [*object]
        @structure[:uri] = UUID.generate(:urn)
        @structure[:content] = content
      end
    end

    # :call-seq:
    #   annotates?(target) -> true or false
    #
    # Does this annotation object annotate the supplied target?
    def annotates?(target)
      @structure[:about].include?(target)
    end

    # :call-seq:
    #   target -> String or Array
    #
    # The identifier(s) for the annotated resource. This is considered the
    # target of the annotation, that is the resource (or resources) the
    # annotation content is "somewhat about".
    #
    # The target can either be a singleton or a list of targets.
    def target
      about = @structure[:about]
      about.length == 1 ? about[0] : about.dup
    end

    # :call-seq:
    #   add_target(new_target, ...) -> added target(s)
    #
    # Add a new target, or targets, to this annotation.
    #
    # The target(s) added are returned.
    def add_target(add)
      @structure[:about] += [*add]

      @edited = true
      add
    end

    # :call-seq:
    #   remove_target(target) -> target or nil
    #
    # Remove a target from this annotation. An annotation must always have a
    # target so this method will do nothing if it already has only one target.
    #
    # If the target can be removed then it is returned, otherwise nil is
    # returned.
    def remove_target(remove)
      return if @structure[:about].length == 1

      @edited = true
      @structure[:about].delete(remove)
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
      cleaned = Util.clean_json(@structure)
      cleaned[:about] = target
      cleaned.to_json(*a)
    end

  end

end
