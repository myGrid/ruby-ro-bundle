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
    json_empty = { :empty1 => "", :empty2 => [], :empty3 => {} }
    json_mix = json_ok.merge(json_nil).merge(json_empty)
    empty = {}

    assert_not_same json_ok, ROBundle::Util.clean_json(json_ok)
    assert_equal json_ok, ROBundle::Util.clean_json(json_ok)
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

  def test_absolute_uri
    assert ROBundle::Util.is_absolute_uri?("http://example.com/test.txt")
    assert ROBundle::Util.is_absolute_uri?("urn:uuid:and-so-on")
    assert ROBundle::Util.is_absolute_uri?(URI.parse("http://example.com/test.txt"))
    assert ROBundle::Util.is_absolute_uri?(URI.parse("urn:uuid:and-so-on"))
    refute ROBundle::Util.is_absolute_uri?("/file.txt")
    refute ROBundle::Util.is_absolute_uri?("file.txt")
    refute ROBundle::Util.is_absolute_uri?(URI.parse("/file.txt"))
    refute ROBundle::Util.is_absolute_uri?(URI.parse("file.txt"))
    refute ROBundle::Util.is_absolute_uri?(":file.txt")
    refute ROBundle::Util.is_absolute_uri?("")
    refute ROBundle::Util.is_absolute_uri?(nil)
  end

  def test_strip_slash
    str1 = ""
    str2 = "/"
    str3 = "test"
    str4 = "test/path"
    str5 = "test/path/trailing/"

    assert_nil ROBundle::Util.strip_leading_slash(nil)
    assert_equal str1, ROBundle::Util.strip_leading_slash(str1)
    assert_equal str1, ROBundle::Util.strip_leading_slash(str2)
    assert_equal str3, ROBundle::Util.strip_leading_slash("/#{str3}")
    assert_equal str4, ROBundle::Util.strip_leading_slash("/#{str4}")
    assert_equal str5, ROBundle::Util.strip_leading_slash("/#{str5}")
  end

end
