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

  def test_clean_json
    json_ok = { :one => "one", :uri => URI.parse("/file.txt") }
    json_nil = { :nil => nil }
    json_empty = { :empty => "" }
    json_mix = json_ok.merge(json_nil).merge(json_empty)
    empty = {}

    assert_same json_ok, ROBundle::Util.clean_json(json_ok)
    assert_equal empty, ROBundle::Util.clean_json(json_nil)
    assert_equal empty, ROBundle::Util.clean_json(json_empty)
    assert_equal json_ok, ROBundle::Util.clean_json(json_mix)
  end

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
