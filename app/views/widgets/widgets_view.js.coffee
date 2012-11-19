#= require environment
#= require views/composite_view
#= require views/widgets/search_view
#= require views/widgets/concept_map_view

class Coreon.Views.Widgets.WidgetsView extends Coreon.Views.CompositeView

  id: "coreon-widgets"

  initialize: ->
    super
    @search = new Coreon.Views.Widgets.SearchView
    @map = new Coreon.Views.Widgets.ConceptMapView

  render: ->
    @append @search, @map
    super
