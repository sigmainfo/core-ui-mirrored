#= require environment
#= require views/composite_view
#= require views/widgets/search_view

class Coreon.Views.Widgets.WidgetsView extends Coreon.Views.CompositeView

  id: "coreon-widgets"

  initialize: ->
    super
    @search = new Coreon.Views.Widgets.SearchView

  render: ->
    @append @search
    super
