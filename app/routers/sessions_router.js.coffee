#= require environment

class Coreon.Routers.SessionsRouter extends Backbone.Router

  initialize: (@view) ->

  routes:
    "logout": "destroy"

  navigate: (path, options = {}) ->
    if options.reload? and not konacha?
      location.replace path
    else
      super

  destroy: ->
    @view.model.get("session")?.destroy()
    @view.model.unset "session"
    @navigate "/", reload: on

