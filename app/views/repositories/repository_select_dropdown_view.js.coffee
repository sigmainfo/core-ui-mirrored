#= require environment
#= require templates/repositories/repository_select_dropdown

class Coreon.Views.Repositories.RepositorySelectDropdownView extends Backbone.View

    id: "coreon-repository-select-dropdown"

    template: Coreon.Templates["repositories/repository_select_dropdown"]

    render: ->
      current = @model.currentRepository()
      repositories = (repository for repository in @model.get("repositories") when repository.id isnt current.id)
      @$el.html @template repositories: repositories
      @
