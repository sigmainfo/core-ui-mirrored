#= require environment

class Coreon.Models.TaxonomyNode extends Backbone.Model

  defaults:
    properties: []

  label: ->
    for prop in @get "properties"
      if prop.key is "label"
        label = prop.value
        break

    label or @id
