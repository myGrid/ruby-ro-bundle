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
          refute b.commit_required?

          assert(b.find_entry("mimetype").local_header_offset == 0)
          assert_equal("application/vnd.wf4ever.robundle+zip", b.mimetype)

          # Try and get something from the manifest before it exists
          assert_nothing_raised(Errno::ENOENT) do
            b.id
          end

          # Manifest has been accessed so has been populated with defaults.
          assert b.commit_required?
        end
      end

      assert_nothing_raised(ZipContainer::MalformedContainerError, ZipContainer::ZipError) do
        ROBundle::File.verify!(filename)
      end
    end
  end

  def test_add_file_aggregates
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      entry1 = "test1.json"
      entry2 = "test2.json"
      entry3 = "test3.json"

      assert_nothing_raised do
        bundle = ROBundle::File.create(filename) do |b|
          assert b.aggregates.empty?
          assert_nil b.find_entry(entry1)
          assert b.commit_required?

          agg = b.add(entry1, $man_ex3, :aggregate => false)
          assert b.aggregates.empty?
          assert_not_nil b.find_entry(entry1)
          assert b.commit_required?
          assert_nil agg

          agg = b.add(entry2, $man_ex3)
          assert b.aggregate?(entry2)
          assert_not_nil b.find_entry(entry2)
          assert agg.instance_of?(ROBundle::Aggregate)

          b.add_aggregate(entry3, $man_ex3)
          assert b.aggregate?(entry3)
          assert_not_nil b.find_entry(entry3)

          new_agg = ROBundle::Aggregate.new("/#{entry1}")
          b.add_aggregate(new_agg)
          assert b.aggregate?(entry1)
        end

        refute bundle.commit_required?
      end

      ROBundle::File.open(filename) do |b|
        refute b.aggregates.empty?
        refute b.commit_required?

        assert b.aggregate?(entry1)
        assert_not_nil b.find_entry(entry1)

        assert b.aggregate?(entry2)
        assert_not_nil b.find_entry(entry2)

        assert b.aggregate?(entry3)
        assert_not_nil b.find_entry(entry3)
      end
    end
  end

  def test_add_uri_aggregates
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      entry1 = "http://www.example.com/example"
      entry2 = URI.parse(entry1)

      assert_nothing_raised do
        bundle = ROBundle::File.create(filename) do |b|
          agg = b.add_aggregate(entry1)
          assert b.aggregate?(entry1)
          assert_nil b.find_entry(entry1)
          assert agg.instance_of?(ROBundle::Aggregate)

          b.add_aggregate(entry2)
          assert b.aggregate?(entry2)
          assert_nil b.find_entry(entry2)
          assert b.commit_required?
        end

        refute bundle.commit_required?
      end

      ROBundle::File.open(filename) do |b|
        refute b.aggregates.empty?
        refute b.commit_required?

        assert b.aggregate?(entry1)
        assert_nil b.find_entry(entry1)

        assert b.aggregate?(entry2)
        assert_nil b.find_entry(entry2)
      end
    end
  end

  def test_add_history
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      entry1 = "test1.json"
      entry2 = ".ro/test2.json"

      assert_nothing_raised do
        bundle = ROBundle::File.create(filename) do |b|
          assert b.history.empty?
          assert_nil b.find_entry(entry1)

          b.add(entry1, $man_ex3, :aggregate => false)
          assert_not_nil b.find_entry(entry1)

          b.add_history(entry2, $man_ex3)
          assert_not_nil b.find_entry(entry2)
          assert entry_in_history_list(entry2, b.history)

          b.add_history(entry1)
          assert entry_in_history_list(entry1, b.history)
          assert b.commit_required?
        end

        refute bundle.commit_required?
      end

      ROBundle::File.open(filename) do |b|
        refute b.history.empty?

        assert entry_in_history_list(entry1, b.history)
        assert_not_nil b.find_entry(entry1)

        assert_not_nil b.find_entry(entry2)
        assert entry_in_history_list(entry2, b.history)
      end
    end
  end

end
