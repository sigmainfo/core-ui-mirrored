#= require environment
#= require views/simple_view
#= require templates/widgets/concept_map

class Coreon.Views.Widgets.ConceptMapView extends Coreon.Views.SimpleView

  id: "coreon-concept-map"

  className: "widget"

  template: Coreon.Templates["widgets/concept_map"]

  render: ->
    @$el.html @template()
    @
