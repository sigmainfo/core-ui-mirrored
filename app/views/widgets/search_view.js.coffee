#= require environment
#= require templates/widgets/search
#= require views/widgets/search_target_select_view

class Coreon.Views.Widgets.SearchView extends Backbone.View
  id: "coreon-search"

  template: Coreon.Templates["widgets/search"]

  events:
    "submit form": "submitHandler"

  initialize: ->
    @selector = new Coreon.Views.Widgets.SearchTargetSelectView

  render: ->
    @$el.html @template label: I18n.t "search.submit"
    @$("#coreon-search-query").after @selector.render().$el
    @

  submitHandler: (event) ->
    event.preventDefault()
    event.stopPropagation()
    Backbone.history.navigate "concepts/search?#{@$('form').serialize()}", trigger: true
