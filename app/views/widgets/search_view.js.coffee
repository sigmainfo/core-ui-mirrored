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
    @add @selector
    @selector.on "focus", @onClickedToFocus, @
    @searchType.on "change:selectedTypeIndex", @onChangeSelectedType, @ 

  delegateEvents: ->
    super
    @selector.delegateEvents()

  undelegateEvents: ->
    super
    @selector.undelegateEvents()

  render: ->
    @$el.html @template label: I18n.t "search.submit"
    @selector.render().insertAfter "#coreon-search-query"
    @

  submitHandler: (event) ->
    event.preventDefault()
    event.stopPropagation()
    path = switch @searchType.getSelectedType()
      when "all"
        "search?"
      else
        "concepts/search?t=#{@searchType.getSelectedType()}&"
    path += @$('form').serialize()
    Backbone.history.navigate path, trigger: true

  onClickedToFocus: (event) ->
    @$("input#coreon-search-query").focus()

  onFocus: (event) ->
    @selector.hideHint()

  onBlur: (event) ->
    @selector.revealHint() unless @$("input#coreon-search-query").val()

  onChangeSelectedType: (event) ->
    @$("input#coreon-search-query").val ""
