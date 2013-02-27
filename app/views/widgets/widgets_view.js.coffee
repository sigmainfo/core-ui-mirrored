#= require environment
#= require jquery.ui.resizable
#= require views/composite_view
#= require views/widgets/search_view
#= require views/widgets/concept_map_view
#= require collections/concept_nodes

class Coreon.Views.Widgets.WidgetsView extends Coreon.Views.CompositeView

  id: "coreon-widgets"

  initialize: ->
    super
    @search = new Coreon.Views.Widgets.SearchView
    @map = new Coreon.Views.Widgets.ConceptMapView
      model: new Coreon.Collections.ConceptNodes( [], hits: @model.hits )

  setElement: (element, delegate) ->
    super
    @$el.resizable
      handles: "w"
      containment: "document"
      minWidth: 240
      start: (event, ui) =>
        ui.originalPosition.left = @$el.position().left
      resize: (event, ui) =>
        @$("svg").attr "width", ui.size.width
      stop: (event, ui) =>
        @$el.css("left", "auto")

  render: ->
    @$el.append @search.render().$el
    @$el.append @map.render().$el
    super
