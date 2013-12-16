#= require environment
#= require models/repository
#= require models/search
#= require models/concept
#= require models/concept_search
#= require collections/hits
#= require collections/clips
#= require views/repositories/repository_view

class Coreon.Routers.RepositoriesRouter extends Backbone.Router

  routes:
    "": "root"

  _bindRoutes: ->
    super
    @route /^([0-9a-f]{24})$/, "show"
    @route /^([0-9a-f]{24})\/search\/([^/]+)/, "search"

  initialize: (@view) ->

  root: ->
    if repo = @view.repository(null)
      @navigate repo.id, trigger: yes, replace: yes
    else
      @navigate "logout"

  show: (id) ->
    Coreon.Collections.Hits.collection().reset []

    if repo = @view.repository id
      @navigate repo.id
      screen = new Coreon.Views.Repositories.RepositoryView model: repo
      @view.switch screen
    else
      @navigate "", trigger: yes, replace: yes
