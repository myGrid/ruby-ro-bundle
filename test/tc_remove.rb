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

      ROBundle::File.open(filename) do |b|
        assert b.aggregate?(rm_file)
        assert_not_nil b.find_entry(rm_file)
        num_agg = b.aggregates.length
        num_ann = b.annotations.length

        b.remove(rm_file)

        refute b.aggregate?(rm_file)
        assert_nil b.find_entry(rm_file)
        assert_equal num_agg - 1, b.aggregates.length
        assert_equal num_ann - 4, b.annotations.length
      end
    end
  end

end
