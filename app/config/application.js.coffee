#= require environment
#= require models/session
#= require collections/hits
#= require views/application_view
#= require routers/search_router
#= require routers/concepts_router

class Coreon.Application

  constructor: ->
    throw new Error "Coreon application does already exist" if Coreon.application?
    @initialize.apply @, arguments
    Coreon.application = @

  initialize: (@options = {}) ->
    _(@options).defaults
      el         : "#app"
      auth_root  : "/api/auth/"
      graph_root : "/api/graph/"
      
    @session = new Coreon.Models.Session _(@options).pick "auth_root", "graph_root"
    @session.fetch()

    @hits = new Coreon.Collections.Hits

  start: (options = {}) ->
    _(@options).extend options

    @view = new Coreon.Views.ApplicationView
      model: @
      el: @options.el

    @view.render()

    @routers =
      search_router: new Coreon.Routers.SearchRouter
        view: @view
        concepts: @concepts
        app: @
      concepts_router: new Coreon.Routers.ConceptsRouter
        collection: @concepts
        view: @view
        app: @

    Backbone.history.start pushState: true, silent: not @session.get "active"
    @

  destroy: ->
    @session.deactivate()
    delete Coreon.application

  sync: (method, model, options) ->
    @session.connections.sync method, model, options
