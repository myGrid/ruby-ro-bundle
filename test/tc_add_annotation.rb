#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'test/unit'
require "ro-bundle"

class TestAddAnnotation < Test::Unit::TestCase

  def test_add_annotation_object
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      ro = "/"
      uri = "http://www.example.com"
      entry = "test_1.json"
      annotation1 = ROBundle::Annotation.new(ro)
      annotation2 = ROBundle::Annotation.new(entry, uri)
      annotation3 = ROBundle::Annotation.new(annotation1)

      bundle = ROBundle::File.create(filename) do |b|
        b.add_aggregate(entry, $man_ex3)

        ann = b.add_annotation(annotation1)
        b.add_annotation(annotation2)
        b.add_annotation(annotation3)

        assert_equal annotation1, ann

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        assert_same annotation1, ann1

        assert b.annotation?(ann2.uri)
        assert_same annotation2, ann2
        assert_equal uri, ann2.content

        assert b.annotation?(ann3.uri)
        assert_same annotation3, ann3
        assert b.commit_required?
      end

      refute bundle.commit_required?

      ROBundle::File.open(filename) do |b|
        refute b.aggregates.empty?
        refute b.annotations.empty?
        refute b.commit_required?

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        assert_not_same annotation1, ann1

        assert b.annotation?(ann2.uri)
        assert_not_same annotation2, ann2
        assert_equal uri, ann2.content

        assert b.annotation?(ann3.uri)
        assert_not_same annotation3, ann3
      end
    end
  end

  def test_add_annotation_object_no_target
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      entry = "test.html"
      annotation = ROBundle::Annotation.new(entry)

      ROBundle::File.create(filename) do |b|
        assert_raises(Errno::ENOENT) do
          b.add_annotation(annotation)
        end
      end

      ROBundle::File.open(filename) do |b|
        assert b.aggregates.empty?
        assert b.annotations.empty?
        refute b.commit_required?
      end
    end
  end

  def test_add_annotation_no_target
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      entry = "test.html"

      ROBundle::File.create(filename) do |b|
        assert_raises(Errno::ENOENT) do
          b.add_annotation(entry)
        end
      end

      ROBundle::File.open(filename) do |b|
        assert b.aggregates.empty?
        assert b.annotations.empty?
        refute b.commit_required?
      end
    end
  end

  def test_add_file_annotations_to_aggregate
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      entry = "test_1.json"
      entry2 = "test_2.json"

      ROBundle::File.create(filename) do |b|
        b.add_aggregate(entry, $man_ex3)
        b.add_aggregate(entry2, $man_ex3)

        ann = b.add_annotation(entry, $man_ex3)
        b.add_annotation(entry, $man_ex3, :aggregate => true)
        b.add_annotation(entry, entry2)

        assert ann.instance_of?(ROBundle::Annotation)

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)

        assert b.annotation?(ann3)
        assert b.aggregate?(ann3.content)
      end

      ROBundle::File.open(filename) do |b|
        refute b.aggregates.empty?
        refute b.annotations.empty?
        refute b.commit_required?

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)

        assert b.annotation?(ann3)
        assert b.aggregate?(ann3.content)
      end
    end
  end

  def test_add_uri_annotations_to_aggregate
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      entry = "test_1.json"
      uri1 = "http://www.example.com/example1"
      uri2 = URI.parse("http://www.example.com/example2")
      uri3 = "http://www.example.com/example3"

      ROBundle::File.create(filename) do |b|
        b.add_aggregate(entry, $man_ex3)
        b.add_aggregate(uri3)

        ann = b.add_annotation(entry, uri1)
        b.add_annotation(entry, uri2, :aggregate => true)
        b.add_annotation(entry, uri3)

        assert ann.instance_of?(ROBundle::Annotation)

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)

        assert b.annotation?(ann3)
        assert b.aggregate?(ann3.content)
      end

      ROBundle::File.open(filename) do |b|
        refute b.aggregates.empty?
        refute b.annotations.empty?
        refute b.commit_required?

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)

        assert b.annotation?(ann3)
        assert b.aggregate?(ann3.content)
      end
    end
  end

  def test_add_content_annotations_to_aggregate
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      entry = "test_1.json"
      uri = "http://www.example.com/example1"
      content = File.read($man_ex3)

      ROBundle::File.create(filename) do |b|
        b.add_aggregate(entry, $man_ex3)
        b.add_aggregate(uri)

        ann = b.add_annotation(entry, content)
        b.add_annotation(entry, content, :aggregate => true)
        b.add_annotation(uri, content)

        assert ann.instance_of?(ROBundle::Annotation)

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)
        assert_equal content, b.file.read(".ro/#{ann1.content}")

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)
        assert_equal content, b.file.read(ann2.content)

        assert b.annotation?(ann3)
        refute b.aggregate?(ann3.content)
        assert_equal content, b.file.read(".ro/#{ann3.content}")
      end

      ROBundle::File.open(filename) do |b|
        refute b.aggregates.empty?
        refute b.annotations.empty?
        refute b.commit_required?

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)
        assert_equal content, b.file.read(".ro/#{ann1.content}")

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)
        assert_equal content, b.file.read(ann2.content)

        assert b.annotation?(ann3)
        refute b.aggregate?(ann3.content)
        assert_equal content, b.file.read(".ro/#{ann3.content}")
      end
    end
  end

  def test_add_file_annotations_to_uri
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      uri1 = "http://www.example.com/example1"
      uri2 = URI.parse("http://www.example.com/example2")
      entry1 = "test_1.json"
      entry2 = "test_2.json"
      entry3 = "test_3.json"

      ROBundle::File.create(filename) do |b|
        b.add_aggregate(uri2)
        b.add_aggregate(entry3, $man_ex3)

        ann = b.add_annotation(uri1, entry1)
        b.add_annotation(uri1, entry2, :aggregate => true)
        b.add_annotation(uri2, entry3)

        assert ann.instance_of?(ROBundle::Annotation)

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)

        assert b.annotation?(ann2.uri)
        refute b.aggregate?(uri1)
        assert b.aggregate?(ann2.content)

        assert b.annotation?(ann3)
        assert b.aggregate?(ann3.content)
      end

      ROBundle::File.open(filename) do |b|
        refute b.aggregates.empty?
        refute b.annotations.empty?
        refute b.commit_required?

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)

        assert b.annotation?(ann2.uri)
        refute b.aggregate?(uri1)
        assert b.aggregate?(ann2.content)

        assert b.annotation?(ann3)
        assert b.aggregate?(ann3.content)
      end
    end
  end

  def test_add_uri_annotations_to_uri
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      uri1 = "http://www.example.com/example1"
      uri2 = URI.parse("http://www.example.com/example2")
      uri3 = "http://www.example.com/example3"
      uri4 = "http://www.example.com/example4"
      uri5 = "http://www.example.com/example5"

      ROBundle::File.create(filename) do |b|
        b.add_aggregate(uri3)
        b.add_aggregate(uri5)

        ann = b.add_annotation(uri1, uri2)
        b.add_annotation(uri1, uri4, :aggregate => true)
        b.add_annotation(uri3, uri5)

        assert ann.instance_of?(ROBundle::Annotation)

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)

        assert b.annotation?(ann2.uri)
        refute b.aggregate?(uri1)
        assert b.aggregate?(ann2.content)

        assert b.annotation?(ann3)
        assert b.aggregate?(ann3.content)
      end

      ROBundle::File.open(filename) do |b|
        refute b.aggregates.empty?
        refute b.annotations.empty?
        refute b.commit_required?

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)

        assert b.annotation?(ann2.uri)
        refute b.aggregate?(uri1)
        assert b.aggregate?(ann2.content)

        assert b.annotation?(ann3)
        assert b.aggregate?(ann3.content)
      end
    end
  end

  def test_add_content_annotations_to_uri
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      uri1 = "http://www.example.com/example1"
      uri2 = "http://www.example.com/example2"
      content = File.read($man_ex3)

      ROBundle::File.create(filename) do |b|
        b.add_aggregate(uri2)

        ann = b.add_annotation(uri1, content)
        b.add_annotation(uri1, content, :aggregate => true)
        b.add_annotation(uri2, content)

        assert ann.instance_of?(ROBundle::Annotation)

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)
        assert_equal content, b.file.read(".ro/#{ann1.content}")

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)
        assert_equal content, b.file.read(ann2.content)

        assert b.annotation?(ann3)
        refute b.aggregate?(ann3.content)
        assert_equal content, b.file.read(".ro/#{ann3.content}")
      end

      ROBundle::File.open(filename) do |b|
        refute b.aggregates.empty?
        refute b.annotations.empty?
        refute b.commit_required?

        ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)
        assert_equal content, b.file.read(".ro/#{ann1.content}")

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)
        assert_equal content, b.file.read(ann2.content)

        assert b.annotation?(ann3)
        refute b.aggregate?(ann3.content)
        assert_equal content, b.file.read(".ro/#{ann3.content}")
      end
    end
  end

  def test_add_file_annotations_to_annotation
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      ro = "/"
      uri = "http://www.example.com"
      annotation1 = ROBundle::Annotation.new(ro)
      annotation2 = ROBundle::Annotation.new(ro, uri)
      entry = "test_1.json"

      ROBundle::File.create(filename) do |b|
        b.add_aggregate(entry, $man_ex3)
        b.add_annotation(annotation1)
        b.add_annotation(annotation2)

        ann = b.add_annotation(annotation1.uri, $man_ex3)
        b.add_annotation(annotation1, $man_ex3, :aggregate => true)
        b.add_annotation(annotation2, entry)

        assert ann.instance_of?(ROBundle::Annotation)

        _, _, ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)

        assert b.annotation?(ann3)
        assert b.aggregate?(ann3.content)
      end

      ROBundle::File.open(filename) do |b|
        refute b.aggregates.empty?
        refute b.annotations.empty?
        refute b.commit_required?

        _, _, ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)

        assert b.annotation?(ann3)
        assert b.aggregate?(ann3.content)
      end
    end
  end

  def test_add_uri_annotations_to_annotation
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      ro = "/"
      uri = "http://www.example.com"
      annotation = ROBundle::Annotation.new(ro, uri)
      uri1 = "http://www.example.com/example1"
      uri2 = URI.parse("http://www.example.com/example2")
      uri3 = "http://www.example.com/example3"

      ROBundle::File.create(filename) do |b|
        b.add_aggregate(uri3)
        b.add_annotation(annotation)

        ann = b.add_annotation(annotation, uri1)
        b.add_annotation(annotation, uri2, :aggregate => true)
        b.add_annotation(annotation, uri3)

        assert ann.instance_of?(ROBundle::Annotation)

        _, ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)

        assert b.annotation?(ann3)
        assert b.aggregate?(ann3.content)
      end

      ROBundle::File.open(filename) do |b|
        refute b.aggregates.empty?
        refute b.annotations.empty?
        refute b.commit_required?

        _, ann1, ann2, ann3 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)

        assert b.annotation?(ann3)
        assert b.aggregate?(ann3.content)
      end
    end
  end

  def test_add_content_annotations_to_annotation
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test.bundle")

      ro = "/"
      uri = "http://www.example.com"
      annotation = ROBundle::Annotation.new(ro, uri)
      content = File.read($man_ex3)

      ROBundle::File.create(filename) do |b|
        b.add_annotation(annotation)

        ann = b.add_annotation(annotation, content)
        b.add_annotation(annotation, content, :aggregate => true)

        assert ann.instance_of?(ROBundle::Annotation)

        _, ann1, ann2 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)
        assert_equal content, b.file.read(".ro/#{ann1.content}")

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)
        assert_equal content, b.file.read(ann2.content)
      end

      ROBundle::File.open(filename) do |b|
        refute b.aggregates.empty?
        refute b.annotations.empty?
        refute b.commit_required?

        _, ann1, ann2 = b.annotations

        assert b.annotation?(ann1.uri)
        refute b.aggregate?(ann1.content)
        assert_equal content, b.file.read(".ro/#{ann1.content}")

        assert b.annotation?(ann2.uri)
        assert b.aggregate?(ann2.content)
        assert_equal content, b.file.read(ann2.content)
      end
    end
  end

end
