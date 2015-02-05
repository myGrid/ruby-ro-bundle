#------------------------------------------------------------------------------
# Copyright (c) 2014, 2015 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'test/unit'
require "ro-bundle"
require "helpers/fake_manifest"

class TestManifest < Test::Unit::TestCase

  def setup
    @manifest = FakeManifest.new($man_ex3)
  end

  def test_top_level
    assert @manifest.context.instance_of?(Array)

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

    annotations = @manifest.annotations
    assert annotations.instance_of?(Array)
    annotations.each do |a|
      assert a.instance_of?(ROBundle::Annotation)
    end
  end

  def test_ensure_copied_lists
    %w(authored_by history).map(&:to_sym).each do |m|
      list = @manifest.send(m)
      list << "new item"
      assert_not_equal list, @manifest.send(m)
    end
  end

  def test_change_context
    old = @manifest.context
    context = "http://example.com/context"
    @manifest.add_context(context)

    assert @manifest.context.include?(context)
    assert @manifest.context.include?(old[0])
    assert_equal old[0], @manifest.context[1]
    assert @manifest.edited?
  end

  def test_change_id
    old = @manifest.id
    @manifest.id = "/new"

    assert_equal "/new", @manifest.id
    assert_not_equal old, @manifest.id
    assert @manifest.edited?
  end

  def test_change_aggregate
    change = @manifest.aggregates[0]
    change.add_author "Robert Haines"

    assert @manifest.aggregates[0].edited?
    assert @manifest.edited?
  end

  def test_change_annotation
    change = @manifest.annotations[1]
    change.content = "http://example.com/different"

    assert @manifest.annotations[1].edited?
    assert @manifest.edited?
  end

  def test_remove_annotation_by_object
    remove = @manifest.annotations[0]
    assert_equal 3, @manifest.annotations.length

    @manifest.remove_annotation(remove)
    assert_equal 1, @manifest.annotations.length
    assert @manifest.edited?

    @manifest.remove_annotation(remove)
    assert_equal 1, @manifest.annotations.length
    assert @manifest.edited?
  end

  def test_remove_annotation_by_id
    id = "urn:uuid:d67466b4-3aeb-4855-8203-90febe71abdf"
    assert_equal 3, @manifest.annotations.length

    @manifest.remove_annotation(id)
    assert_equal 1, @manifest.annotations.length
    assert @manifest.edited?

    @manifest.remove_annotation(id)
    assert_equal 1, @manifest.annotations.length
    assert @manifest.edited?
  end

  def test_remove_annotation_by_about
    about = "/folder/soup.jpeg"
    assert_equal 3, @manifest.annotations.length

    @manifest.remove_annotation(about)
    assert_equal 1, @manifest.annotations.length
    assert @manifest.edited?

    @manifest.remove_annotation(about)
    assert_equal 1, @manifest.annotations.length
    assert @manifest.edited?
  end

  def test_remove_non_existent_annotations
    about = "not-here!"
    id = about
    assert_equal 3, @manifest.annotations.length

    @manifest.remove_annotation(about)
    assert_equal 3, @manifest.annotations.length
    refute @manifest.edited?

    @manifest.remove_annotation(id)
    assert_equal 3, @manifest.annotations.length
    refute @manifest.edited?
  end

  def test_remove_aggregate_by_object
    remove = @manifest.aggregates[0]
    assert_equal 4, @manifest.aggregates.length
    assert_equal 3, @manifest.annotations.length

    @manifest.remove_aggregate(remove)
    assert_equal 3, @manifest.aggregates.length
    assert_equal 1, @manifest.annotations.length
    assert @manifest.edited?

    @manifest.remove_aggregate(remove)
    assert_equal 3, @manifest.aggregates.length
    assert_equal 1, @manifest.annotations.length
    assert @manifest.edited?
  end

  def test_remove_aggregate_by_file
    remove = "/folder/soup.jpeg"
    assert_equal 4, @manifest.aggregates.length
    assert_equal 3, @manifest.annotations.length

    @manifest.remove_aggregate(remove)
    assert_equal 3, @manifest.aggregates.length
    assert_equal 1, @manifest.annotations.length
    assert @manifest.edited?

    @manifest.remove_aggregate(remove)
    assert_equal 3, @manifest.aggregates.length
    assert_equal 1, @manifest.annotations.length
    assert @manifest.edited?
  end

  def test_remove_aggregate_by_uri
    remove = "http://example.com/blog/"
    assert_equal 4, @manifest.aggregates.length
    assert_equal 3, @manifest.annotations.length

    @manifest.remove_aggregate(remove)
    assert_equal 3, @manifest.aggregates.length
    assert_equal 3, @manifest.annotations.length
    assert @manifest.edited?

    @manifest.remove_aggregate(remove)
    assert_equal 3, @manifest.aggregates.length
    assert_equal 3, @manifest.annotations.length
    assert @manifest.edited?
  end

  def test_remove_non_existent_aggregates
    file = "not-here!"
    uri = "http://example.com/not-here"
    assert_equal 4, @manifest.aggregates.length

    @manifest.remove_aggregate(file)
    assert_equal 4, @manifest.aggregates.length
    refute @manifest.edited?

    @manifest.remove_aggregate(uri)
    assert_equal 4, @manifest.aggregates.length
    refute @manifest.edited?
  end

  def test_empty_manifest
    manifest = FakeManifest.new($man_empty)

    assert manifest.context.instance_of?(Array)
    assert manifest.edited?

    assert_equal("/", manifest.id)

    assert_nil manifest.created_on
    assert_nil manifest.authored_on
    assert_nil manifest.created_by
    assert manifest.authored_by.instance_of?(Array)

    assert manifest.history.instance_of?(Array)
    assert manifest.aggregates.instance_of?(Array)
    assert manifest.annotations.instance_of?(Array)
  end

  def test_invalid_manifest
    manifest = FakeManifest.new($man_invalid)

    assert_raises(JSON::ParserError) do
      assert manifest.context.instance_of?(Array)
    end
  end

  def test_manifest_graph_statement_preserved
    manifest = FakeManifest.new($man_ex6)

    json = JSON.parse(JSON.generate(manifest))
    assert_not_nil json["@graph"]
  end

end
