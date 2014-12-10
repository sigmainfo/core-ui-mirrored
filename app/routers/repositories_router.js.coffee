#= require environment

class Coreon.Routers.RepositoriesRouter extends Backbone.Router

  routes:
    '': 'index'

  _bindRoutes: ->
    super
    @route /^([0-9a-f]{24})\/?(?:concepts)?\/?$/, 'show'

  initialize: (@app) ->

  session: ->
    @app.get('session')

  index: ->
    repo_id = null
    if last_repo = localStorage.getItem('last-repo')
      repo_id = @session().repositoryByCacheId(last_repo)?.id
    else
      repo_id = @session().get('repositories')?[0]?.id
    if repo_id?
      @navigate repo_id, trigger: yes, replace: yes
    else
      @navigate 'logout'

  show: (id) ->
    @app.set 'selection', null
    @app.selectRepository id
