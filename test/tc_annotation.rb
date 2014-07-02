#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'test/unit'
require "ro-bundle"

class TestAnnotation < Test::Unit::TestCase

  def setup
    @about = "/file.txt"
    @content = [ "/", "http://www.example.com/example.txt" ]
    @id = UUID.generate(:urn)

    @json = {
      :about => @about,
      :content => @content,
      :annotation => @id
    }
  end

  def test_create
    an = ROBundle::Annotation.new(@about)

    assert_equal @about, an.about
    assert_nil an.content
  end

  def test_create_from_json
    an = ROBundle::Annotation.new(@json)

    assert_equal @about, an.about
    assert_equal @content, an.content
    assert_equal @id, an.annotation
  end

  def test_generate_annotation_id
    an = ROBundle::Annotation.new(@about)
    id = an.annotation

    assert id.instance_of?(String)
    assert id.start_with?("urn:uuid:")
    assert_same id, an.annotation
  end

end
