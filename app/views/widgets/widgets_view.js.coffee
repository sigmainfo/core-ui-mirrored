#= require environment
#= require jquery.ui.resizable
#= require views/widgets/search_view
#= require views/widgets/languages_view
#= require views/widgets/concept_map_view
#= require views/widgets/clipboard_view
#= require collections/concept_nodes
#= require modules/droppable

class Coreon.Views.Widgets.WidgetsView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Droppable

  id: "coreon-widgets"

  options:
    resizeDelay: 500

  initialize: ->
    settings = Coreon.application?.repositorySettings('widgets')
    @$el.width settings.width if settings.width?
    @subviews = []

    @droppableOn @$el, "ui-droppable-widgets",
      greedy: false
      disableForeigners: true
      fake: true

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
      model: new Coreon.Models.SearchType
    @$el.append search.render().$el
    @subviews.push search

    languages= new Coreon.Views.Widgets.LanguagesView
    @$el.append languages.render().$el
    @subviews.push languages

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
    Coreon.application?.repositorySettings('widgets', layout)

  saveLayout: _.debounce saveLayout, 500
