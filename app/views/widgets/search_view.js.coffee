#= require environment
#= require views/composite_view
#= require templates/widgets/search
#= require models/search_type
#= require views/widgets/search_target_select_view

class Coreon.Views.Widgets.SearchView extends Coreon.Views.CompositeView

  id: "coreon-search"

  template: Coreon.Templates["widgets/search"]

  events:
    "submit form": "submitHandler"
    "focus input#coreon-search-query": "onFocus"
    "blur input#coreon-search-query": "onBlur"

  initialize: ->
    super
    @searchType = new Coreon.Models.SearchType

    @selector = new Coreon.Views.Widgets.SearchTargetSelectView
      model: @searchType
    @selector.render()
    @selector.on "focus", @onClickedToFocus, @
    @searchType.on "change:selectedTypeIndex", @onChangeSelectedType, @ 

  render: ->
    @$el.html @template label: I18n.t "search.submit"
    @$("#coreon-search-query").after @selector.render().$el
    super

  submitHandler: (event) ->
    event.preventDefault()
    event.stopPropagation()
    type = @searchType.getSelectedType()
    query = encodeURIComponent @$('input#coreon-search-query').val()
    switch type
      when "all"
        Backbone.history.navigate "search/#{query}"
        Coreon.application.routers.search_router.search query
      else
        Backbone.history.navigate "concepts/search/#{type}/#{query}"
        Coreon.application.routers.concepts_router.search type, query

  onClickedToFocus: (event) ->
    @$("input#coreon-search-query").focus()

  onFocus: (event) ->
    @selector.hideHint()

  onBlur: (event) ->
    @selector.revealHint() unless @$("input#coreon-search-query").val()

  onChangeSelectedType: (event) ->
    @$("input#coreon-search-query").val ""
