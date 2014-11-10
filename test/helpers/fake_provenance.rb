#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

# Fake up a mixed in provenance module for easy testing.
class FakeProvenance
  include ROBundle::Provenance

  def initialize
    @edited = false
  end

  def edited?
    @edited
  end

  private

  # This structure purposefully has no :authoredBy or :authoredOn fields.
  def structure
    @structure ||= init_provenance_defaults(
      {
        :createdBy => { :name => "Robert Haines" },
        :createdOn => "2014-08-20T11:30:00+01:00",
        :retrievedOn => "2014-11-10T18:30:00Z"
      }
    )
  end
end
