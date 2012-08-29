#= require environment
#= require templates/widgets/search

class Coreon.Views.Widgets.SearchView extends Backbone.View
  id: "coreon-search"

  template: Coreon.Templates["widgets/search"]

  events:
    "submit form": "submitHandler"

  render: ->
    @$el.html @template label: I18n.t "search.submit"
    @

  submitHandler: (event) ->
    event.preventDefault()
    event.stopPropagation()
    Backbone.history.navigate "concepts/search?#{@$('form').serialize()}", trigger: true
