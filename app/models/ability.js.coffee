#= require environment

class Coreon.Models.Ability extends Backbone.Model

  defaults:
    role: "user"

  can: (action, target) ->
    role = @get "role"
    if action is "read"
      return true
    if role is "maintainer"
      return true
    false
