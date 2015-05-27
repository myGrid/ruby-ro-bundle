#------------------------------------------------------------------------------
# Copyright (c) 2014, 2015 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------


require 'test/unit'
require "ro-bundle"

class TestAggregate < Test::Unit::TestCase

  def test_simple_file
    file = "/good.txt"
    type = "text/plain"
    agg = ROBundle::Aggregate.new(file, type)

    assert_equal file, agg.uri
    assert_equal "good.txt", agg.file_entry
    assert_equal type, agg.mediatype
  end

  def test_simple_uri
    uri = "http://example.com/good.txt"
    agg = ROBundle::Aggregate.new(uri)

    assert_nil agg.mediatype
    assert_nil agg.file_entry
    assert_equal uri, agg.uri
  end

  def test_simple_uri_object
    uri = URI.parse("http://example.com/good.txt")
    agg = ROBundle::Aggregate.new(uri)

    assert_nil agg.mediatype
    assert_nil agg.file_entry
    assert_equal uri.to_s, agg.uri
  end

  def test_complex_file
    file = "/good.txt"
    type = "text/plain"

    json = {
      :uri => file,
      :mediatype => type,
      :createdOn => "2013-02-12T19:37:32.939Z",
      :createdBy => { "name" => "Robert Haines" },
      :authoredOn => "2013-02-12T19:37:32.939Z",
      :authoredBy => { "name" => "Robert Haines" }
    }

    agg = ROBundle::Aggregate.new(json)

    assert_equal file, agg.uri
    assert_equal type, agg.mediatype
    assert agg.created_on.instance_of?(Time)
    assert agg.created_by.instance_of?(ROBundle::Agent)
    assert agg.authored_on.instance_of?(Time)
    assert agg.authored_by.instance_of?(Array)
    assert agg.authored_by[0].instance_of?(ROBundle::Agent)
  end

  def test_filepath_encoding_handling
    file = "file with spaces.txt"
    agg = ROBundle::Aggregate.new(file)
    assert_equal "/file%20with%20spaces.txt",agg.uri
    assert_equal file,agg.file_entry
  end

  def test_encoded_uri
    uri = "http://example.com/encoded%20uri"

    json = {
        :uri => uri
    }
    agg = ROBundle::Aggregate.new(json)

    assert_equal uri, agg.uri

    agg = ROBundle::Aggregate.new(uri)
    assert_equal uri, agg.uri
  end

  def test_complex_uri
    uri = "http://example.com/good.txt"

    json = {
      :uri => uri
    }

    agg = ROBundle::Aggregate.new(json)

    assert_nil agg.file_entry
    assert_nil agg.mediatype
    assert_equal uri, agg.uri
  end

  def test_json_output_file
    file = "/good.txt"
    type = "text/plain"
    time = "2013-02-12T19:37:32.939Z"
    json = {
      :uri => file,
      :mediatype => type,
      :createdOn => time,
      :createdBy => { :name => "Robert Haines" }
    }

    agg = ROBundle::Aggregate.new(json)
    json = JSON.parse(JSON.generate(agg))

    assert_equal file, json["uri"]
    assert_equal type, json["mediatype"]
    assert_equal time, json["createdOn"]
  end

end
