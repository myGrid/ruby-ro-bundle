#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'test/unit'
require "ro-bundle"

class Example3Manifest < ROBundle::Manifest

  private

  def contents
    File.read("test/data/example3-manifest.json")
  end

end

class TestManifest < Test::Unit::TestCase

  def setup
    @manifest = Example3Manifest.new
  end

  def test_top_level
    assert_equal("/", @manifest.id)

    assert @manifest.created_on.instance_of?(Time)
    assert_nil @manifest.authored_on

    creator = @manifest.created_by
    assert creator.instance_of?(ROBundle::Agent)

    authors = @manifest.authored_by
    assert authors.instance_of?(Array)

    history = @manifest.history
    assert history.instance_of?(Array)
    history.each do |h|
      assert h.instance_of?(String)
    end

    aggregates = @manifest.aggregates
    assert aggregates.instance_of?(Array)
    aggregates.each do |a|
      assert a.instance_of?(ROBundle::Aggregate)
    end
  end

end
