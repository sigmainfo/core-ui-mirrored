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
    type = @searchType.getSelectedType()
    query = encodeURIComponent @$('input#coreon-search-query').val()
    repo = Backbone.history.fragment.split("/")[0]
    path = if type is "all"
      "#{repo}/search/#{query}"
    else
      "#{repo}/concepts/#{type}/search/#{query}"
    Backbone.history.navigate path
    Backbone.history.loadUrl()

  onClickedToFocus: (event) ->
    @$("input#coreon-search-query").focus()

  onFocus: (event) ->
    @selector.hideHint()

  onBlur: (event) ->
    @selector.revealHint() unless @$("input#coreon-search-query").val()

  onChangeSelectedType: (event) ->
    @$("input#coreon-search-query").val ""
