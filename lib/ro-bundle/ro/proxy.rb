#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

#
module ROBundle

  # A class to represent an ORE Proxy for an Aggregate as per the specification
  #of the
  # {JSON structure}[https://researchobject.github.io/specifications/bundle/#json-structure]
  # of the manifest.
  class Proxy < ManifestEntry

    # :call-seq:
    #   new
    #   new(folder)
    #   new(folder, filename)
    #
    # Create a new ORE Proxy. If +folder+ is not supplied then "/" is assumed.
    def initialize(object = "", filename = nil)
      super()

      if object.instance_of?(Hash)
        @structure = object
        init_provenance_defaults(@structure)
      else
        @structure = {}
        @structure[:uri] = UUID.generate(:urn)
        @structure[:folder] = folder_slashes(object)
        @structure[:filename] = filename
      end
    end

    # :call-seq:
    #   folder
    #
    # Return the folder field of this Proxy.
    def folder
      @structure[:folder]
    end

    # :call-seq:
    #   filename
    #
    # Return the filename field of this Proxy.
    def filename
      @structure[:filename]
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
    # Write this Proxy out as a json string. Takes the same options as
    # JSON#generate.
    def to_json(*a)
      JSON.generate(Util.clean_json(@structure),*a)
    end

    private

    def folder_slashes(folder)
      folder = "/#{folder}" unless folder.start_with?('/')
      folder = "#{folder}/" unless folder.end_with?('/')
      folder
    end

  end
end
