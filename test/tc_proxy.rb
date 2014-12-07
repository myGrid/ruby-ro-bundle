#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

require 'test/unit'
require "ro-bundle"
require "helpers/fake_manifest"

class TestProxy < Test::Unit::TestCase

  def setup
    @manifest = FakeManifest.new($man_ex3)

    @folder = "folder"
    @file = "file.txt"
    @proxy = ROBundle::Proxy.new(@folder, @file)
  end

  def test_read_no_proxy
    assert_nil @manifest.aggregates[2].proxy
  end

  def test_new_empty_proxy
    proxy = ROBundle::Proxy.new
    assert ROBundle::Util.is_absolute_uri?(proxy.uri)
    assert_equal "/", proxy.folder
    assert_nil proxy.filename
  end

  def test_new_proxy
    assert ROBundle::Util.is_absolute_uri?(@proxy.uri)
    assert_equal "/#{@folder}/", @proxy.folder
    assert_equal @file, @proxy.filename
  end

  def test_read_proxy
    proxy = @manifest.aggregates[3].proxy

    assert_not_nil proxy
    assert_equal "/folder/", proxy.folder
    assert_equal "external.txt", proxy.filename
  end

end
