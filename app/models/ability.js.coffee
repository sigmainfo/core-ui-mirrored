#= require environment

class Coreon.Models.Ability extends Backbone.Model

  initialize: (@session)->

  can: (action, target) ->
    roles = @session.currentRepository().get("user_roles")
    is_user = "user" in roles
    is_maintainer = "maintainer" in roles

    (action is 'read' and is_user) or is_maintainer
