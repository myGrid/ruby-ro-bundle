#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------


require 'test/unit'
require "ro-bundle"

class TestAggregate < Test::Unit::TestCase

  def test_simple_file
    assert_nothing_raised(ROBundle::InvalidAggregateError) do
      file = "/good.txt"
      agg = ROBundle::Aggregate.new(file)

      assert_nil agg.uri
      assert_equal file, agg.file
    end
  end

  def test_simple_uri
    assert_nothing_raised(ROBundle::InvalidAggregateError) do
      uri = "http://example.com/good.txt"
      agg = ROBundle::Aggregate.new(uri)

      assert_nil agg.file
      assert_equal URI.parse(uri), agg.uri
    end
  end

  def test_simple_uri_object
    assert_nothing_raised(ROBundle::InvalidAggregateError) do
      uri = URI.parse("http://example.com/good.txt")
      agg = ROBundle::Aggregate.new(uri)

      assert_nil agg.file
      assert_equal uri, agg.uri
    end
  end

  def test_bad_aggregates
    assert_raise(ROBundle::InvalidAggregateError) do
      ROBundle::Aggregate.new(":bad")
    end

    assert_raise(ROBundle::InvalidAggregateError) do
      ROBundle::Aggregate.new("bad/bad.txt")
    end

    assert_raise(ROBundle::InvalidAggregateError) do
      ROBundle::Aggregate.new([])
    end

    assert_raise(ROBundle::InvalidAggregateError) do
      ROBundle::Aggregate.new({})
    end
  end

  def test_complex_file
    assert_nothing_raised(ROBundle::InvalidAggregateError) do
      file = "/good.txt"
      type = "text/plain"

      json = {
        "file" => file,
        "mediatype" => type,
        "createdOn" => "2013-02-12T19:37:32.939Z",
        "createdBy" => { "name" => "Robert Haines" }
      }

      agg = ROBundle::Aggregate.new(json)

      assert_nil agg.uri
      assert_equal file, agg.file
      assert_equal type, agg.mediatype
      assert agg.created_on.instance_of?(Time)
      assert agg.created_by.instance_of?(ROBundle::Agent)
    end
  end

  def test_complex_uri
    assert_nothing_raised(ROBundle::InvalidAggregateError) do
      uri = "http://example.com/good.txt"

      json = {
        "uri" => uri
      }

      agg = ROBundle::Aggregate.new(json)

      assert_nil agg.file
      assert_equal URI.parse(uri), agg.uri
    end
  end

end
