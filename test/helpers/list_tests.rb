#------------------------------------------------------------------------------
# Copyright (c) 2014 The University of Manchester, UK.
#
# BSD Licenced. See LICENCE.rdoc for details.
#
# Author: Robert Haines
#------------------------------------------------------------------------------

# Is the given file aggregate in the list of aggregate objects
def file_aggregate_in_list(agg, list)
  list.each do |e|
    return true if e.file == "/#{agg}"
  end

  false
end
