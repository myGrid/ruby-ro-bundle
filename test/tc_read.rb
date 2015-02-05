#------------------------------------------------------------------------------
# Copyright (c) 2014, 2015 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'test/unit'
require "ro-bundle"

class TestRead < Test::Unit::TestCase

  def test_verify_valid
    assert_nothing_raised(ZipContainer::MalformedContainerError, ZipContainer::Error) do
      ROBundle::File.verify!($hello)
    end

    assert ROBundle::File.verify?($hello)
  end

  def test_verify_invalid
    assert_raises(ZipContainer::MalformedContainerError) do
      ROBundle::File.verify!($invalid)
    end

    refute ROBundle::File.verify?($invalid)
  end

  def test_manifest
    ROBundle::File.open($hello) do |b|
      assert_equal("/", b.id)

      assert b.created_on.instance_of?(Time)
      assert_nil b.authored_on

      creator = b.created_by
      assert creator.instance_of?(ROBundle::Agent)

      author = b.authored_by
      assert author.instance_of?(Array)

      history = b.history
      assert history.instance_of?(Array)

      aggregates = b.aggregates
      assert aggregates.instance_of?(Array)

      annotations = b.annotations
      assert annotations.instance_of?(Array)

      refute b.commit_required?
    end
  end

  def test_aggregates
    ROBundle::File.open($hello) do |b|
      assert b.aggregate?(b.id)
      assert b.aggregate?("/")

      assert b.aggregate?("/inputs/name.txt")
      assert b.aggregate?("inputs/name.txt")
    end
  end

end
