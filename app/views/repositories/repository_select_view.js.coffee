#= require environment
#= require templates/repositories/repository_select
#= require views/repositories/repository_select_dropdown_view
#= require modules/helpers
#= require modules/prompt
#= require jquery.ui.position

class Coreon.Views.Repositories.RepositorySelectView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Prompt
  
  id: "coreon-repository-select"

  template: Coreon.Templates["repositories/repository_select"]

  events:
    "click .select": "select"

  initialize: ->
    @listenTo @model, "change:current_repository_id change:repositories", @render

  render: ->
    if repository = @model.currentRepository()
      @$el.html @template
        repository: repository
        single: @model.get("repositories")?.length is 1
      @fitWidth()
    @

  fitWidth: ->
    dropdown = new Coreon.Views.Repositories.RepositorySelectDropdownView
      model: @model
    $("#coreon-modal").append dropdown.render().$el
    @$("h4.current").width dropdown.$("ul").outerWidth()
    dropdown.remove()

  renderDropDown: ->

  select: (event) ->
    event.preventDefault()
    event.stopPropagation()
    dropdown = new Coreon.Views.Repositories.RepositorySelectDropdownView
      model: @model
    @prompt dropdown
    dropdown.$el.position
      my: "left top"
      at: "left bottom"
      of: @$("h4.current")
