#= require environment
#= require models/clip

collection = null

class Coreon.Collections.Clips extends Backbone.Collection

  @collection: ->
    collection ?= new @

  model: Coreon.Models.Clip

