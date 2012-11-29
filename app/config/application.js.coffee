#= require environment
#= require models/account
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
      
    @account = new Coreon.Models.Account _(@options).pick "auth_root", "graph_root"
    @account.fetch()

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

    Backbone.history.start pushState: true
    @

  destroy: ->
    @account.deactivate()
    delete Coreon.application

  sync: (method, model, options) ->
    @account.connections.sync method, model, options
