#= require environment
#= require models/concept_node

class Coreon.Collections.ConceptNodes extends Backbone.Collection

  model: Coreon.Models.ConceptNode

  initialize: (models, @options) ->

  tree: ->
    id: "root"
    children: []
