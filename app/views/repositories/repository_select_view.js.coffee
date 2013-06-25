#= require environment
#= require templates/repositories/repository_select
#= require views/repositories/repository_select_dropdown_view

class Coreon.Views.Repositories.RepositorySelectView extends Backbone.View
  
  id: "coreon-repository-select"

  template: Coreon.Templates["repositories/repository_select"]

  events:
    "click .select": "select"

  initialize: ->
    @listenTo @model, "change:current_repository_id change:repositories", @render

  render: ->
    @options.app.prompt null
    if repository = @model.currentRepository()
      @$el.html @template
        repository: repository
        single: @model.get("repositories")?.length is 1
    @

  select: (event) ->
    event.preventDefault()
    event.stopPropagation()
    dropdown = new Coreon.Views.Repositories.RepositorySelectDropdownView
      model: @model
      app: @options.app
    @options.app.prompt dropdown
    dropdown.$("ul.options").position
      my: "left top"
      at: "left bottom"
      of: @$ "h4.current"