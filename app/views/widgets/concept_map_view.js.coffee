#= require environment
#= require views/simple_view
#= require templates/widgets/concept_map
#= require d3

class Coreon.Views.Widgets.ConceptMapView extends Coreon.Views.SimpleView

  id: "coreon-concept-map"

  className: "widget"

  template: Coreon.Templates["widgets/concept_map"]

  initialize: ->
    @layout = d3.layout.tree() 
    @model.on "hit:update", @_onHitUpdate, @

  render: ->
    @$el.html @template()
    @

  _onHitUpdate: ->
    @layout.nodes @model.tree()

  dissolve: ->
    @model.off null, null, @
