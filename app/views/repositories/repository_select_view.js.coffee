#= require environment
#= require templates/repositories/repository_select

class Coreon.Views.Repositories.RepositorySelectView extends Backbone.View
  
  id: "coreon-repository-select"

  template: Coreon.Templates["repositories/repository_select"]

  render: ->
    if session = @model.get("session")
      repository = session.currentRepository() or new Coreon.Views.Models.Repository
      single = session.get("repositories")?.length is 1
      @$el.html @template repository: repository, single: single
    else
      @$el.empty()
    @

