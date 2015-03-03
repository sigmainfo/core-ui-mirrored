#= require environment

Coreon.Lib.sortByKey = (collection, key, missingKeyLabel = '') ->
  sorted = {}
  for item in collection
    keyValue = item[key] || missingKeyLabel
    sorted[keyValue] ?= []
    sorted[keyValue].push item
  sorted
