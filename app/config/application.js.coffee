#= require environment
#= require models/session
#= require views/application_view
#= require routers/concepts_router
#= require routers/search_router

class Coreon.Application extends Backbone.Model

  defaults:
    el: "#coreon-app"

  initialize: ->
    unless Coreon.application?
      Coreon.application = @
    else
      throw new Error "Coreon application already initialized"
    view = new Coreon.Views.ApplicationView model: @, el: @get "el"
    new router view: view for name, router of Coreon.Routers

  start: ->
    unless @has "auth_root"
      throw new Error "Authorization service root URL not given"
    Backbone.history.start silent: on, pushState: on
    Coreon.Models.Session.load(@get "auth_root").always (session) =>
      @set "session", session
    @
