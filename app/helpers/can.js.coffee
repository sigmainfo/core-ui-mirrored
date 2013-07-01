#= require environment

Coreon.Helpers.can = (action, target) ->
  Coreon.application.get("session")?.ability().can arguments...
