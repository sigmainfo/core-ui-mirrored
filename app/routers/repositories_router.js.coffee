#= require environment
#= require models/repository
#= require views/repositories/repository_view

class Coreon.Routers.RepositoriesRouter extends Backbone.Router

  routes:
    "": "root"

  _bindRoutes: ->
    super
    @route /^([0-9a-f]{24})$/, "show"

  initialize: (@view) ->

  root: ->
    if current = @view.model.get("session").currentRepository()
      @navigate current.id, trigger: yes, replace: yes
    else
      @navigate "logout"

  show: (id) ->
    session = @view.model.get("session")
    session.set "current_repository_id", id
    if repo = session.currentRepository()
      screen = new Coreon.Views.Repositories.RepositoryView model: repo
      @view.switch screen
    else
      @navigate "", trigger: yes, replace: yes
   
