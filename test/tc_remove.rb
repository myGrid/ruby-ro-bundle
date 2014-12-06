#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'test/unit'
require "fileutils"
require "ro-bundle"

class TestRemove < Test::Unit::TestCase

  def test_remove_entry
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")
      FileUtils.cp $hello, filename

      rm_file = "workflow.wfbundle"

      bundle = ROBundle::File.open(filename) do |b|
        assert b.aggregate?(rm_file)
        assert_not_nil b.find_entry(rm_file)
        num_agg = b.aggregates.length
        num_ann = b.annotations.length

        b.remove(rm_file)

        refute b.aggregate?(rm_file)
        assert_nil b.find_entry(rm_file)
        assert_equal num_agg - 1, b.aggregates.length
        assert_equal num_ann - 4, b.annotations.length
        assert b.commit_required?
      end

      refute bundle.commit_required?

      removed_annotations = [
        ".ro/annotations/workflow.wfdesc.ttl",
        ".ro/annotations/d2757512-7149-4ff7-b7f8-78de3e3a2bd5.ttl"
      ]

      ROBundle::File.open(filename) do |b|
        assert_nil b.find_entry(rm_file)
        removed_annotations.each do |ann|
          assert_nil b.find_entry(ann, :include_hidden => true)
        end
      end
    end
  end

  def test_remove_aggregate_by_filename
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")
      FileUtils.cp $hello, filename

      rm_file = "workflow.wfbundle"

      ROBundle::File.open(filename) do |b|
        assert b.aggregate?(rm_file)
        assert_not_nil b.find_entry(rm_file)
        num_agg = b.aggregates.length
        num_ann = b.annotations.length

        b.remove_aggregate(rm_file)

        refute b.aggregate?(rm_file)
        assert_nil b.find_entry(rm_file)
        assert_equal num_agg - 1, b.aggregates.length
        assert_equal num_ann - 4, b.annotations.length
      end
    end
  end

  def test_remove_aggregate_by_object
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")
      FileUtils.cp $hello, filename

      ROBundle::File.open(filename) do |b|
        rm_file = b.aggregates[0]
        assert b.aggregate?(rm_file.uri)
        assert_not_nil b.find_entry(rm_file.file_entry)
        num_agg = b.aggregates.length
        num_ann = b.annotations.length

        b.remove_aggregate(rm_file)

        refute b.aggregate?(rm_file.uri)
        assert_nil b.find_entry(rm_file.file_entry)
        assert_equal num_agg - 1, b.aggregates.length
        assert_equal num_ann - 4, b.annotations.length
      end
    end
  end

  def test_remove_aggregate_by_filename_keep_file
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")
      FileUtils.cp $hello, filename

      rm_file = "workflow.wfbundle"

      ROBundle::File.open(filename) do |b|
        assert b.aggregate?(rm_file)
        assert_not_nil b.find_entry(rm_file)
        num_agg = b.aggregates.length
        num_ann = b.annotations.length

        b.remove_aggregate(rm_file, :keep_file => true)

        refute b.aggregate?(rm_file)
        assert_not_nil b.find_entry(rm_file)
        assert_equal num_agg - 1, b.aggregates.length
        assert_equal num_ann - 4, b.annotations.length
      end
    end
  end

  def test_remove_aggregate_by_object_keep_file
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")
      FileUtils.cp $hello, filename

      ROBundle::File.open(filename) do |b|
        rm_file = b.aggregates[0]
        assert b.aggregate?(rm_file.uri)
        assert_not_nil b.find_entry(rm_file.file_entry)
        num_agg = b.aggregates.length
        num_ann = b.annotations.length

        b.remove_aggregate(rm_file, :keep_file => true)

        refute b.aggregate?(rm_file.uri)
        assert_not_nil b.find_entry(rm_file.file_entry)
        assert_equal num_agg - 1, b.aggregates.length
        assert_equal num_ann - 4, b.annotations.length
      end
    end
  end

end
