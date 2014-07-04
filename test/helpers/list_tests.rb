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

# Is the given file name in the list of history objects
def entry_in_history_list(entry, list)
  name = entry.start_with?(".ro/") ? entry.sub(".ro/", "") : "/#{entry}"
  list.include?(name)
end

# Is the given name in the list of agent objects
def name_in_agent_list(name, list)
  list.each do |e|
    return true if e.name == name
  end

  false
end
