#= require environment

Coreon.Helpers.can = (action, target) ->
  ability = Coreon.application.get("session")?.get("ability")
  ability.can action, target if ability
