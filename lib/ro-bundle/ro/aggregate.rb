#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

#
module ROBundle

  # A class to represent an aggregated resource in a Research Object. It holds
  # standard meta-data for either file or URI resources. An aggregate can only
  # represent a file path OR a URI resource, not both at once.
  #
  # If a file path is passed, it will be correctly encoded into a valid absolute URI. If an absolute URI is passed, it is
  # assumed to already have been encoded.
  class Aggregate < ManifestEntry

    # :call-seq:
    #   new(uri, mediatype)
    #   new(uri)
    #   new(filepath)
    #   new(filepath, mediatype)
    #
    # Create a new file or URI aggregate.
    def initialize(object, mediatype = nil)
      super()

      if object.instance_of?(Hash)
        init_json(object)
      else
        @structure[:uri] = if Util.is_absolute_uri?(object)
                             object.to_s
                           else
                             Addressable::URI.encode(object.start_with?("/") ? object : "/#{object}")
                           end
        @structure[:mediatype] = mediatype
      end
    end

    # :call-seq:
    #   edited? -> true or false
    #
    # Has this aggregate been altered in any way?
    def edited?
      @edited || (proxy.nil? ? false : proxy.edited?)
    end

    # :call-seq:
    #   file_entry
    #
    # The path of this aggregate in "rubyzip" format, i.e. no leading '/'.
    def file_entry
      Addressable::URI.unencode(Util.strip_leading_slash(uri)) unless Util.is_absolute_uri?(uri)
    end

    # :call-seq:
    #   uri
    #
    # The URI of this aggregate. It should be an absolute URI.
    def uri
      @structure[:uri]
    end

    # :call-seq:
    #   mediatype
    #
    # This aggregate's
    # {IANA media type}[http://www.iana.org/assignments/media-types].
    def mediatype
      @structure[:mediatype]
    end

    # :call-seq:
    #   proxy -> Proxy
    #
    # Return this aggregate's ORE proxy as per the specification of the
    # {JSON structure}[https://researchobject.github.io/specifications/bundle/#json-structure]
    # of the manifest.
    def proxy
      @structure[:bundledAs]
    end

    # :call-seq:
    #   to_json(options = nil) -> String
    #
    # Write this Aggregate out as a json string. Takes the same options as
    # JSON#generate.
    def to_json(*a)
      JSON.generate(Util.clean_json(@structure),*a)
    end

    # :stopdoc:
    # For internal use only!
    def stored
      super
      proxy.stored unless proxy.nil?
    end
    # :startdoc:

    private

    def init_json(object)
      @structure = init_provenance_defaults(object)
      @structure[:uri] = object[:uri]
      @structure[:mediatype] = object[:mediatype]
      unless object[:bundledAs].nil?
        @structure[:bundledAs] = Proxy.new(object[:bundledAs])
      end
    end

  end

end
