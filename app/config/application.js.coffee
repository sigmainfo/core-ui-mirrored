#= require environment
#= require models/coreon_session
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

    @session = @lookupExistingSession()
    Coreon.Modules.CoreAPI.on "login", =>
      @session = @lookupExistingSession()

    @hits = new Coreon.Collections.Hits

  lookupExistingSession: ->
    session = new Coreon.Models.CoreonSession
      auth_root: @options.auth_root
    session.fetch()


  start: (options = {}) ->
    _(@options).extend options

    @view = new Coreon.Views.ApplicationView
      model: @
      el: @options.el

    @view.render()

    @routers =
      concepts_router: new Coreon.Routers.ConceptsRouter
        collection: @concepts
        view: @view
        app: @
      search_router: new Coreon.Routers.SearchRouter
        view: @view
        concepts: @concepts
        app: @

    Backbone.history.start pushState: true, silent: not @session?.valid()
    @

  destroy: ->
    @session?.deactivate()
    delete Coreon.application

  sync: (method, model, options) ->
    @session?.sync method, model, options
