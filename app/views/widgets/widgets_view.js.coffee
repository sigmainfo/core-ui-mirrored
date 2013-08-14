#= require environment
#= require jquery.ui.resizable
#= require views/widgets/search_view
#= require views/widgets/concept_map_view
#= require views/widgets/clipboard_view
#= require collections/concept_nodes

class Coreon.Views.Widgets.WidgetsView extends Backbone.View

  id: "coreon-widgets"

  options:
    resizeDelay: 500

  initialize: ->
    settings = @localSettings()
    @$el.width settings.widgets.width if settings.widgets.width?
    @subviews = []


  localSettings: ->
    cache_id = Coreon.application.cacheId()
    try settings = JSON.parse localStorage.getItem cache_id
    finally settings ?= {}
    settings.widgets ?= {}
    settings

  setElement: (element, delegate) ->
    super
    @$el.resizable
      handles: "w"
      containment: "document"
      minWidth: 240
      start: (event, ui) =>
        ui.originalPosition.left = @$el.position().left
      resize: (event, ui) =>
        @map.resize ui.size.width, null
        @saveLayout width: ui.size.width
      stop: (event, ui) =>
        @$el.css
          left: "auto"
          top: "auto"

  render: ->
    subview.remove() for subview in @subviews
    @subviews = []
    
    search = new Coreon.Views.Widgets.SearchView
    @$el.append search.render().$el
    @subviews.push search

    clipboard = new Coreon.Views.Widgets.ClipboardView
    @$el.append clipboard.render().$el
    @subviews.push clipboard

    @map = new Coreon.Views.Widgets.ConceptMapView
      model: new Coreon.Collections.ConceptNodes [],
        hits: Coreon.Collections.Hits.collection()
    @$el.append @map.render().$el
    @subviews.push @map

    @

  saveLayout = (layout) ->
    settings = @localSettings()
    settings.widgets = layout
    cache_id = Coreon.application.cacheId()
    localStorage.setItem cache_id, JSON.stringify settings

  saveLayout: _.debounce saveLayout, 500
