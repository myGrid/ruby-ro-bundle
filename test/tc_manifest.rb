#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'test/unit'
require "ro-bundle"

class Example3Manifest < ROBundle::Manifest

  private

  def contents
    File.read($man_ex3)
  end

end

class TestManifest < Test::Unit::TestCase

  def setup
    @manifest = Example3Manifest.new
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
    %w(authored_by history aggregates annotations).map(&:to_sym).each do |m|
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

  def test_change_created_on
    old = @manifest.created_on
    now = Time.now.to_s
    @manifest.created_on = now

    assert_equal now, @manifest.created_on.to_s
    assert_not_equal old.to_s, @manifest.created_on.to_s
    assert @manifest.edited?
  end

  def test_change_created_by
    agent = ROBundle::Agent.new("Robert Haines")
    @manifest.created_by = agent

    assert_same agent, @manifest.created_by
    assert @manifest.edited?
  end

  def test_created_by_bad_agent
    old = @manifest.created_by
    agent = "Robert Haines"
    @manifest.created_by = agent

    assert_same old, @manifest.created_by
    refute @manifest.edited?
  end

  def test_change_authored_on
    old = @manifest.authored_on
    now = Time.now.to_s
    @manifest.authored_on = now

    assert_equal now, @manifest.authored_on.to_s
    assert_not_equal old.to_s, @manifest.authored_on.to_s
    assert @manifest.edited?
  end

end
