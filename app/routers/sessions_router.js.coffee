#= require environment
#= require models/notification

class Coreon.Routers.SessionsRouter extends Backbone.Router

  initialize: (@app) ->

  routes:
    'logout': 'destroy'

  navigate: (path, options = {}) ->
    if options.reload? and not konacha?
      location.replace '/#{path}'
    else
      super

  destroy: ->
    Coreon.Models.Notification.collection().reset []
    if session = @app.get('session')
      @app.set 'session', null, silent: true
      session.destroy().always =>
        @navigate '', reload: yes
    else
      @navigate '', reload: yes
