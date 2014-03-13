#= require environment

class Coreon.Routers.RepositoriesRouter extends Backbone.Router

  routes:
    '': 'index'

  _bindRoutes: ->
    super
    @route /^([0-9a-f]{24})$/, 'show'

  initialize: (@app) ->

  session: ->
    @app.get('session')

  index: ->
    if repository = @session().get('repositories')?[0]
      @navigate repository.id, trigger: yes, replace: yes
    else
      @navigate 'logout'

  show: (id) ->
    @app.set 'selection', null
    @app.selectRepository id
