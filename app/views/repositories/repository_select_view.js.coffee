#= require environment
#= require templates/repositories/repository_select
#= require modules/helpers
#= require modules/prompt
#= require lib/coreon_select
#= require jquery.ui.position

class Coreon.Views.Repositories.RepositorySelectView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Prompt
  
  id: "coreon-repository-select"

  template: Coreon.Templates["repositories/repository_select"]

  events:
    "change select": "changedSelect"

  initialize: ->
    @listenTo @model, "change:current_repository_id change:repositories", @render

  render: ->
    if repository = @model.currentRepository()
      @$el.html @template
        repository: repository
        repositories: @model.get("repositories")
        single: @model.get("repositories")?.length is 1
        
      @$('select').val(repository.id).coreonSelect()
    else
      @$el.html ''
    @

  changedSelect: (e) ->
    Backbone.history.navigate "/#{$(e.target).val()}", trigger: yes
