#= require environment
#= require models/session
#= require views/application_view
#= require routers/sessions_router
#= require routers/repositories_router
#= require routers/concepts_router
#= require routers/search_router
#= require modules/error_notifications

class Coreon.Application extends Backbone.Model

  defaults:
    el: "#coreon-app"

  initialize: ->
    unless Coreon.application?
      Coreon.application = @
    else
      throw new Error "Coreon application already initialized"
    Coreon.Models.Session.auth_root = @get "auth_root"
    view = new Coreon.Views.ApplicationView model: @, el: @get "el"
    new router view for name, router of Coreon.Routers

  start: ->
    unless @has "auth_root"
      throw new Error "Authorization service root URL not given"
    Coreon.Models.Session.load().always (session) =>
      @set "session", session
    @
