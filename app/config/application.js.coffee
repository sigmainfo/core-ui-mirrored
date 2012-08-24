#= require environment
#= require models/account
#= require collections/concepts
#= require views/application_view
#= require routers/concepts_router

class Coreon.Application

  constructor: ->
    throw new Error "Coreon application does already exist" if Coreon.application?
    @initialize.apply @, arguments
    Coreon.application = @

  initialize: (@options = {}) ->
    _(@options).defaults
      el         : "#app"
      app_root   : "/"
      auth_root  : "/api/auth/"
      graph_root : "/api/graph/"
    
    @account = new Coreon.Models.Account _(@options).pick "auth_root", "graph_root"
    @concepts = new Coreon.Collections.Concepts


  start: (options = {}) ->
    _(@options).extend options

    @view = new Coreon.Views.ApplicationView
      model: @
      el: @options.el

    @routers = 
      concepts_router: new Coreon.Routers.ConceptsRouter @concepts

    Backbone.history.start
      pushState: true
      root: @options.app_root
      silent: true

    @view.render()

    @

  destroy: ->
    @account.deactivate()
    delete Coreon.application
