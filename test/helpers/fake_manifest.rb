#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

# Fake up a manifest for easy testing.
class FakeManifest < ROBundle::Manifest

  def initialize(file)
    @file = file
    super()
  end

  private

  def contents
    File.read(@file)
  end

end
