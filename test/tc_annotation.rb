#------------------------------------------------------------------------------
# Copyright (c) 2014, 2015 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'test/unit'
require "ro-bundle"

class TestAnnotation < Test::Unit::TestCase

  def setup
    @target = [ "/", "/file.txt" ]
    @content = "http://www.example.com/example.txt"
    @id = UUID.generate(:urn)
    @creator = "Robert Haines"
    @time = "2014-08-20T11:30:00+01:00"

    @json = {
      :about => @target,
      :content => @content,
      :uri => @id,
      :createdBy => { :name => @creator },
      :createdOn => @time
    }
  end

  def test_create
    an = ROBundle::Annotation.new(@target)

    assert_equal @target, an.target
    assert_nil an.content
    assert_not_nil an.uri
  end

  def test_create_with_content
    an = ROBundle::Annotation.new(@target, @content)

    assert_equal @target, an.target
    assert_equal @content, an.content
    assert_not_nil an.uri
  end

  def test_create_from_json
    an = ROBundle::Annotation.new(@json)

    assert_equal @target, an.target
    assert_equal @content, an.content
    assert_equal @id, an.uri
    assert an.created_on.instance_of?(Time)
    assert an.created_by.instance_of?(ROBundle::Agent)
  end

  def test_cannot_change_target_directly
    an = ROBundle::Annotation.new(@json)

    assert_equal 2, an.target.length
    an.target << "/more.html"
    assert_equal 2, an.target.length
  end

  def test_change_content
    an = ROBundle::Annotation.new(@json)
    new_content = "/file.txt"
    an.content = new_content

    assert_equal new_content, an.content
  end

  def test_generate_annotation_id
    an = ROBundle::Annotation.new(@target)
    id = an.uri

    assert id.instance_of?(String)
    assert id.start_with?("urn:uuid:")
    assert_same id, an.uri
  end

  def test_json_output_single_target
    an = ROBundle::Annotation.new("/")
    json = JSON.parse(JSON.generate(an))

    assert_equal "/", json["about"]
  end

  def test_json_output_multiple_targets
    an = ROBundle::Annotation.new(@target)
    json = JSON.parse(JSON.generate(an))

    assert_equal @target, json["about"]
  end

  def test_full_json_output
    an = ROBundle::Annotation.new(@json)
    json = JSON.parse(JSON.generate(an))

    assert_equal @target, json["about"]
    assert_equal @content, json["content"]
    assert_equal @id, json["uri"]
    assert_equal @time, json["createdOn"]
    assert_equal @creator, json["createdBy"]["name"]
  end

end
