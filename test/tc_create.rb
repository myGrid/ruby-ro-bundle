#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require "test/unit"
require "tmpdir"
require "ro-bundle"

require "helpers/list_tests"

class TestCreation < Test::Unit::TestCase

  def test_create_empty_bundle
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      assert_nothing_raised do
        ROBundle::File.create(filename) do |b|
          assert(b.on_disk?)
          refute(b.in_memory?)
          refute b.commit_required?

          assert(b.find_entry("mimetype").local_header_offset == 0)
          assert_equal("application/vnd.wf4ever.robundle+zip", b.mimetype)

          # Try and get something from the manifest before it exists
          assert_nothing_raised(Errno::ENOENT) do
            b.id
          end

          # Manifest has been accessed so has been populated with defaults.
          assert b.commit_required?

          b.file.open(".ro/manifest.json", "w") do |m|
            m.puts "{ }"
          end
        end
      end

      assert_nothing_raised(ZipContainer::MalformedContainerError, ZipContainer::ZipError) do
        ROBundle::File.verify!(filename)
      end
    end
  end

  def test_add_aggregates
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      entry1 = "test1.json"
      entry2 = "test2.json"
      entry3 = "test3.json"

      assert_nothing_raised do
        ROBundle::File.create(filename) do |b|
          assert b.aggregates.empty?
          assert_nil b.find_entry(entry1)
          assert b.commit_required?

          b.add(entry1, $man_ex3, :aggregate => false)
          assert b.aggregates.empty?
          assert_not_nil b.find_entry(entry1)
          assert b.commit_required?

          b.add(entry2, $man_ex3)
          assert file_aggregate_in_list(entry2, b.aggregates)
          assert_not_nil b.find_entry(entry2)

          b.add_aggregate(entry3, $man_ex3)
          assert file_aggregate_in_list(entry3, b.aggregates)
          assert_not_nil b.find_entry(entry3)

          new_agg = ROBundle::Aggregate.new("/#{entry1}")
          b.add_aggregate(new_agg)
          assert file_aggregate_in_list(entry1, b.aggregates)
        end
      end

      ROBundle::File.open(filename) do |b|
        refute b.aggregates.empty?
        refute b.commit_required?

        assert file_aggregate_in_list(entry1, b.aggregates)
        assert_not_nil b.find_entry(entry1)

        assert file_aggregate_in_list(entry2, b.aggregates)
        assert_not_nil b.find_entry(entry2)

        assert file_aggregate_in_list(entry3, b.aggregates)
        assert_not_nil b.find_entry(entry3)
      end
    end
  end

  def test_add_history
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      entry1 = "test1.json"
      entry2 = ".ro/test2.json"

      assert_nothing_raised do
        ROBundle::File.create(filename) do |b|
          assert b.history.empty?
          assert_nil b.find_entry(entry1)

          b.add(entry1, $man_ex3, :aggregate => false)
          assert_not_nil b.find_entry(entry1)

          b.add_history(entry2, $man_ex3)
          assert_not_nil b.find_entry(entry2)
          assert entry_in_history_list(entry2, b.history)

          b.add_history(entry1)
          assert entry_in_history_list(entry1, b.history)
        end
      end

      ROBundle::File.open(filename) do |b|
        refute b.history.empty?

        assert entry_in_history_list(entry1, b.history)
        assert_not_nil b.find_entry(entry1)

        assert_not_nil b.find_entry(entry2)
        assert entry_in_history_list(entry2, b.history)
      end
    end
  end

  def test_add_author
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      agent = ROBundle::Agent.new(
        "Robert Haines",
        "https://github.com/hainesr",
        "http://orcid.org/0000-0002-9538-7919"
      )

      name = "Mr. Bigglesworth"

      assert_nothing_raised do
        ROBundle::File.create(filename) do |b|
          assert b.authored_by.empty?
          assert b.commit_required?

          b.add_author(agent)
          assert b.authored_by.include?(agent)
          assert b.commit_required?

          b.add_author(name)
          assert name_in_agent_list(name, b.authored_by)
        end
      end

      ROBundle::File.open(filename) do |b|
        refute b.authored_by.empty?
        refute b.commit_required?

        assert name_in_agent_list(agent.name, b.authored_by)
        assert name_in_agent_list(name, b.authored_by)
      end
    end
  end

end
