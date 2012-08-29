#= require environment
#= require views/widgets/search_view

class Coreon.Views.WidgetsView extends Backbone.View
  id: "coreon-widgets"

  initialize: ->
    @search = new Coreon.Views.Widgets.SearchView

  render: ->
    @$el.append @search.render().$el
    @
