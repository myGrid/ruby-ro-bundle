#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'test/unit'
require "ro-bundle"

class TestUtil < Test::Unit::TestCase

  def test_parse_time
    now = Time.now
    iso = now.iso8601

    assert ROBundle::Util.parse_time(iso).instance_of?(Time)
    assert_nil ROBundle::Util.parse_time(nil)
  end

  def test_parse_uri
    str = "http://example.com/test.txt"
    uri = URI.parse(str)

    assert_nil ROBundle::Util.parse_uri(nil)
    assert_same uri, ROBundle::Util.parse_uri(uri)
    assert_equal uri, ROBundle::Util.parse_uri(str)
  end

end
