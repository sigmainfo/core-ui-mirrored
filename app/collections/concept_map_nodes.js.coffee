#= require environment
#= require models/concept_map_node

class Coreon.Collections.ConceptMapNodes extends Backbone.Collection

  model: Coreon.Models.ConceptMapNode

  build: ->
    @reset []
    @add model: Coreon.application.repository()
