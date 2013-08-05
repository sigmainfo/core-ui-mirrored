#= require environment
#= require templates/repositories/repository_select
#= require views/repositories/repository_select_dropdown_view
#= require modules/helpers
#= require modules/prompt

class Coreon.Views.Repositories.RepositorySelectView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Prompt
  
  id: "coreon-repository-select"

  template: Coreon.Templates["repositories/repository_select"]

  events:
    "click .select": "select"

  initialize: ->
    @listenTo @model, "change:current_repository_id change:repositories", @render

  render: ->
    @prompt null
    if repository = @model.currentRepository()
      @$el.html @template
        repository: repository
        single: @model.get("repositories")?.length is 1

    # some magic (or cheating?) to sync sizes of dropdown and menu
    @select()
    @prompt null

    @

  select: (event) ->
    event?.preventDefault()
    event?.stopPropagation()
    dropdown = new Coreon.Views.Repositories.RepositorySelectDropdownView
      model: @model
      app: @options.app
      selector: @$("h4.current")

    @prompt dropdown
    dropdown.fixate()
