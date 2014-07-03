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

require "helpers/list_tests"

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

          # Try and get something from the manifest before it exists
          assert_nothing_raised(Errno::ENOENT) do
            b.id
          end

          b.mkdir(".ro")
          b.file.open(".ro/manifest.json", "w") do |m|
            m.puts "{ }"
          end
        end
      end

      assert_nothing_raised(ZipContainer::MalformedContainerError, ZipContainer::ZipError) do
        ROBundle::File.verify!(filename)
      end
    end
  end

  def test_add_aggregates
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      entry1 = "test1.json"
      entry2 = "test2.json"
      entry3 = "test3.json"

      assert_nothing_raised do
        ROBundle::File.create(filename) do |b|
          assert b.aggregates.empty?
          assert_nil b.find_entry(entry1)

          b.add(entry1, $man_ex3, :aggregate => false)
          assert b.aggregates.empty?
          assert_not_nil b.find_entry(entry1)

          b.add(entry2, $man_ex3)
          assert file_aggregate_in_list(entry2, b.aggregates)
          assert_not_nil b.find_entry(entry2)

          b.add_aggregate(entry3, $man_ex3)
          assert file_aggregate_in_list(entry3, b.aggregates)
          assert_not_nil b.find_entry(entry3)

          b.add_aggregate(entry1)
          assert file_aggregate_in_list(entry1, b.aggregates)
        end
      end
    end
  end

end
