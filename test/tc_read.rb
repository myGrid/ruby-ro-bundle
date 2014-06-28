#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'test/unit'
require "ro-bundle"

class TestRead < Test::Unit::TestCase

  def test_verify
    assert_nothing_raised(ZipContainer::MalformedContainerError, ZipContainer::ZipError) do
      ROBundle::File.verify!($hello)
    end

    assert(ROBundle::File.verify($hello))
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
    end
  end

end
