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

    # :stopdoc:
    def write_annotation_data(source, options)
      uuid = UUID.generate

      if options[:aggregate]
        entry = uuid
        content = "/#{uuid}"
      else
        mk_annotations_dir
        content = "#{@annotations_directory.name}/#{uuid}"
        entry = "#{full_name}/#{content}"
      end

      if ::File.exist?(source)
        container.add(entry, source, options)
      else
        container.file.open(entry, "w") do |annotation|
          annotation.write source.to_s
        end

        if options[:aggregate]
          @manifest.add_aggregate(entry)
        end
      end

      content
    end
    # :startdoc:

    private

    def mk_annotations_dir
      dir_name = "#{full_name}/#{@annotations_directory.name}"
      if container.find_entry(dir_name, :include_hidden => true).nil?
        container.mkdir dir_name
      end
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
