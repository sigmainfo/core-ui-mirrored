#= require environment
#= require templates/widgets/search
#= require models/search_type
#= require views/widgets/search_target_select_view
#= require helpers/repository_path

class Coreon.Views.Widgets.SearchView extends Backbone.View

  id: "coreon-search"

  template: Coreon.Templates["widgets/search"]

  events:
    "submit form#coreon-search-form"  : "submitHandler"
    "focus input#coreon-search-query" : "onFocus"
    "blur input#coreon-search-query"  : "onBlur"

  initialize: ->
    @listenTo @model, "change:selectedTypeIndex", @onChangeSelectedType
    @select = null

  render: ->
    @$el.html @template()

    if old = @select
      old.remove()
      @stopListening old

    @select = new Coreon.Views.Widgets.SearchTargetSelectView
      model: @model
    @$("#coreon-search-query").after @select.render().$el
    @listenTo @select, "focus", @onClickedToFocus

    @

  submitHandler: (event) ->
    event.preventDefault()
    type = @model.getSelectedType()
    query = @$('input#coreon-search-query').val()
    path = if type is "all"
      Coreon.Helpers.repositoryPath("search/#{query}")
    else
      Coreon.Helpers.repositoryPath("concepts/search/#{type}/#{query}")

    Backbone.history.navigate path[1..]
    Backbone.history.loadUrl()

  onClickedToFocus: (event) ->
    @$("input#coreon-search-query").focus()

  onFocus: (event) ->
    @select?.hideHint()

  onBlur: (event) ->
    @select?.revealHint() unless @$("input#coreon-search-query").val()

  onChangeSelectedType: (event) ->
    @$("input#coreon-search-query").val ""
