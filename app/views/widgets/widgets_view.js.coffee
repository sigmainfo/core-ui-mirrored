#= require environment
#= require jquery.ui.resizable
#= require views/composite_view
#= require views/widgets/search_view
#= require views/widgets/concept_map_view
#= require collections/concept_nodes

class Coreon.Views.Widgets.WidgetsView extends Coreon.Views.CompositeView

  id: "coreon-widgets"

  options:
    resizeDelay: 500

  initialize: ->
    super
    @search = new Coreon.Views.Widgets.SearchView
    # @map = new Coreon.Views.Widgets.ConceptMapView
      # model: new Coreon.Collections.ConceptNodes( [], hits: @model.hits )
    # if Coreon.application?
    #   if layout = Coreon.application.session.get "coreon-widgets"
    #     @$el.width layout.width

  setElement: (element, delegate) ->
    super
    # @$el.resizable
    #   handles: "w"
    #   containment: "document"
    #   minWidth: 240
    #   start: (event, ui) =>
    #     ui.originalPosition.left = @$el.position().left
    #   resize: (event, ui) =>
    #     @map.resize ui.size.width, null
    #     @saveLayout width: ui.size.width
    #   stop: (event, ui) =>
    #     @$el.css("left", "auto")

  render: ->
    @$el.append @search.render().$el
    # @$el.append @map.render().$el
    super

  # saveLayout = (layout) -> 
  #   if Coreon.application?
  #     Coreon.application?.session.save @id, layout

  # saveLayout: _.debounce saveLayout, 500
