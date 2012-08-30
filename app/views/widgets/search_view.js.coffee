#= require environment
#= require templates/widgets/search
#= require models/search_type
#= require views/widgets/search_target_select_view

class Coreon.Views.Widgets.SearchView extends Backbone.View
  id: "coreon-search"

  template: Coreon.Templates["widgets/search"]

  events:
    "submit form": "submitHandler"
    "focus input#coreon-search-query": "onFocus"
    "blur input#coreon-search-query": "onBlur"

  initialize: ->
    @searchType = new Coreon.Models.SearchType
    @selector = new Coreon.Views.Widgets.SearchTargetSelectView
      model: @searchType
    @selector.on "focus", @onClickedToFocus, @

  render: ->
    @$el.html @template label: I18n.t "search.submit"
    @$("#coreon-search-query").after @selector.render().$el
    @

  submitHandler: (event) ->
    event.preventDefault()
    event.stopPropagation()
    searchParam = if @searchType.getSelectedType() == "all" then "" else "/#{@searchType.getSelectedType()}"
    Backbone.history.navigate "concepts/search#{searchParam}?#{@$('form').serialize()}", trigger: true

  onClickedToFocus: (event) ->
    @$("input#coreon-search-query").focus()

  onFocus: (event) ->
    @selector.hideHint()

  onBlur: (event) ->
    @selector.revealHint() unless @$("input#coreon-search-query").val()

