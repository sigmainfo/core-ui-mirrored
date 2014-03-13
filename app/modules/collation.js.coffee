#= require environment

labelComparator = (a, b) ->
  [a, b] = [a, b].map (item) -> item.get('label').toLowerCase?() or null
  a.localeCompare b

Coreon.Modules.Collation =

  sortBy: (key, list = @) ->
    list.slice().sort labelComparator
