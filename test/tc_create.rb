#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require "test/unit"
require "tmpdir"
require "ro-bundle"

class TestCreation < Test::Unit::TestCase

  def test_create_empty_bundle
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      assert_nothing_raised do
        ROBundle::File.create(filename) do |b|
          assert(b.on_disk?)
          refute(b.in_memory?)

          assert(b.find_entry("mimetype").local_header_offset == 0)
          assert_equal("application/vnd.wf4ever.robundle+zip", b.mimetype)
        end
      end

      assert_nothing_raised(ZipContainer::MalformedContainerError, Zip::ZipError) do
        ZipContainer::Container.verify!(filename)
      end
    end
  end

end
