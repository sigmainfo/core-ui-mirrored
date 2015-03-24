#= require environment
#= require jquery.ui.resizable
#= require views/widgets/search_view
#= require views/widgets/languages_view
#= require views/panels/term_list_panel
#= require views/panels/concept_map_panel
#= require collections/concept_map_nodes
#= require modules/helpers
#= require modules/droppable
#= require models/term_list

class Coreon.Views.Widgets.WidgetsView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Droppable

  id: "coreon-widgets"


  initialize: ->
    @subviews = []

    @droppableOn @$el, "ui-droppable-widgets",
      greedy: false
      disableForeigners: false
      fake: true

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

    @

  remove: ->
    super
    subview.remove() for subview in @subviews
    @subviews = []
