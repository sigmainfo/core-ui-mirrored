#= require environment
#= require templates/search

class Coreon.Views.SearchView extends Backbone.View
  id: "coreon-search"

  template: Coreon.Templates["search"]

  render: ->
    @$el.html @template()
    @
