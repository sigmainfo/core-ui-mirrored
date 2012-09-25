#= require environment
#= require views/composite_view
#= require views/widgets/search_view

class Coreon.Views.Widgets.WidgetsView extends Coreon.Views.CompositeView
  id: "coreon-widgets"

  initialize: ->
    super
    @search = new Coreon.Views.Widgets.SearchView

  render: ->
    @$el.append @search.render().$el
    super

  delegateEvents: ->
    super
    @search.delegateEvents()

  undelegateEvents: ->
    super
    @search.undelegateEvents()
