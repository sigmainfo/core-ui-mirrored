#= require environment
#= require templates/widgets/search

class Coreon.Views.Widgets.SearchView extends Backbone.View
  id: "coreon-search"

  template: Coreon.Templates["widgets/search"]

  render: ->
    @$el.html @template()
    @
