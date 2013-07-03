#= require environment
#= require models/hit

collection = null

class Coreon.Collections.Hits extends Backbone.Collection

  @collection: ->
    collection ?= new @

  model: Coreon.Models.Hit

  findByResult: (result) ->
    for hit in @models
      return hit if hit.get("result") is result
    null
