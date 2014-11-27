#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'test/unit'
require "ro-bundle"
require "helpers/fake_provenance"

class TestProvenance < Test::Unit::TestCase

  def setup
    @prov = FakeProvenance.new

    @agent = ROBundle::Agent.new(
      "Robert Haines",
      "https://github.com/hainesr",
      "http://orcid.org/0000-0002-9538-7919"
    )
  end

  def test_created_on
    assert @prov.created_on.instance_of?(Time)
  end

  def test_change_created_on
    old = @prov.created_on
    now = Time.now.to_s
    @prov.created_on = now

    assert @prov.created_on.instance_of?(Time)
    assert_equal now, @prov.created_on.to_s
    assert_not_equal old.to_s, @prov.created_on.to_s
    assert @prov.edited?
  end

  def test_created_by
    creator = @prov.created_by
    assert creator.instance_of?(ROBundle::Agent)
    assert_equal creator.name, "Robert Haines"
  end

  def test_change_created_by
    agent = ROBundle::Agent.new("Matt Gamble")
    @prov.created_by = agent

    assert_same agent, @prov.created_by
    assert @prov.edited?
  end

  def test_created_by_string_agent
    old = @prov.created_by
    agent = "Stian Soiland-Reyes"
    @prov.created_by = agent

    assert @prov.created_by.instance_of?(ROBundle::Agent)
    assert_not_same old, @prov.created_by
    assert @prov.edited?
  end

  def test_authored_on
    assert_nil @prov.authored_on
  end

  def test_change_authored_on
    old = @prov.authored_on
    now = Time.now.to_s
    @prov.authored_on = now

    assert @prov.authored_on.instance_of?(Time)
    assert_equal now, @prov.authored_on.to_s
    assert_not_equal old.to_s, @prov.authored_on.to_s
    assert @prov.edited?
  end

  def test_authored_by
    assert @prov.authored_by.instance_of?(Array)
  end

  def test_add_author
    name = "Mr. Bigglesworth"

    assert @prov.authored_by.empty?

    author = @prov.add_author(@agent)
    assert @prov.authored_by.include?(@agent)
    assert_same @agent, author
    assert @prov.edited?

    author = @prov.add_author(name)
    assert name_in_agent_list(name, @prov.authored_by)
    assert author.instance_of?(ROBundle::Agent)
    assert @prov.edited?
  end

  def test_remove_author_by_object
    name = "Mr. Bigglesworth"

    author = @prov.add_author(name)
    refute @prov.authored_by.empty?
    assert name_in_agent_list(name, @prov.authored_by)

    @prov.remove_author(author)
    assert @prov.authored_by.empty?
    refute name_in_agent_list(name, @prov.authored_by)
  end

  def test_remove_authors_by_name
    name = "Robert Haines"
    @prov.add_author(@agent)
    @prov.add_author(name)

    assert_equal 2, @prov.authored_by.length
    assert name_in_agent_list(name, @prov.authored_by)

    @prov.remove_author(name)
    assert @prov.authored_by.empty?
    refute name_in_agent_list(name, @prov.authored_by)
  end

  def test_retrieved_by
    retrievor = @prov.retrieved_by
    assert retrievor.instance_of?(ROBundle::Agent)
    assert_equal retrievor.name, "Robert Haines"
  end

  def test_change_retrieved_by
    agent = ROBundle::Agent.new("Matt Gamble")
    @prov.retrieved_by = agent

    assert_same agent, @prov.retrieved_by
    assert @prov.edited?
  end

  def test_retrieved_by_string_agent
    old = @prov.retrieved_by
    agent = "Stian Soiland-Reyes"
    @prov.retrieved_by = agent

    assert @prov.retrieved_by.instance_of?(ROBundle::Agent)
    assert_not_same old, @prov.retrieved_by
    assert @prov.edited?
  end

  def test_retrieved_from
    assert @prov.retrieved_from.instance_of?(String)
  end

  def test_change_retrieved_from
    old = @prov.retrieved_from
    uri = "http://example.com:8080"
    @prov.retrieved_from = uri

    assert @prov.retrieved_from.instance_of?(String)
    assert_not_equal old, @prov.retrieved_from
    assert @prov.edited?
  end

  def test_change_retrieved_from_uri_object
    old = @prov.retrieved_from
    uri = URI.parse("http://example.com:8080")
    @prov.retrieved_from = uri

    assert @prov.retrieved_from.instance_of?(String)
    assert_not_equal old, @prov.retrieved_from
    assert @prov.edited?
  end

  def test_change_retrieved_from_fail
    old = @prov.retrieved_from
    uri = "www.example.com"
    @prov.retrieved_from = uri

    assert_equal old, @prov.retrieved_from
    refute @prov.edited?
  end

  def test_retrieved_on
    assert @prov.retrieved_on.instance_of?(Time)
  end

  def test_change_retrieved_on
    old = @prov.retrieved_on
    now = Time.now.to_s
    @prov.retrieved_on = now

    assert @prov.retrieved_on.instance_of?(Time)
    assert_equal now, @prov.retrieved_on.to_s
    assert_not_equal old.to_s, @prov.retrieved_on.to_s
    assert @prov.edited?
  end

end
