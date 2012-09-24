#= require environment
#= require models/account
#= require collections/concepts
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
    @concepts = new Coreon.Collections.Concepts

  start: (options = {}) ->
    _(@options).extend options

    @view = new Coreon.Views.ApplicationView
      model: @account
      el: @options.el

    @view.render()

    @routers =
      search_router: new Coreon.Routers.SearchRouter
        view: @view
        concepts: @concepts
      concepts_router: new Coreon.Routers.ConceptsRouter
        collection: @concepts
        view: @view

    Backbone.history.start pushState: true
    @

  destroy: ->
    @account.deactivate()
    delete Coreon.application

  sync: (method, model, options) ->
    @account.connections.sync method, model, options
