#= require environment
#= require templates/repositories/repository_select
#= require templates/repositories/repository_select_dropdown

class Coreon.Views.Repositories.RepositorySelectView extends Backbone.View
  
  id: "coreon-repository-select"

  template: Coreon.Templates["repositories/repository_select"]

  initialize: ->
    @listenTo @model, "change:current_repository_id change:repositories"

  render: ->
    @options.app.prompt null
    if repository = @model.currentRepository()
      @$el.html @template
        repository: repository
        single: @model.get("repositories")?.length is 1
    @

