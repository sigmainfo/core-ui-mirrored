#= require environment
#= require models/notification

class Coreon.Routers.SessionsRouter extends Backbone.Router

  initialize: (@view) ->

  routes:
    "logout": "destroy"

  navigate: (path, options = {}) ->
    if options.reload? and not konacha?
      location.replace "/#{path}"
    else
      super

  destroy: ->
    Coreon.Models.Notification.collection().reset []
    if session = @view.model.get "session"
      session.destroy()
      @view.model.unset "session"
    @navigate "", reload: yes