#= require environment

class Coreon.Collections.Hits extends Backbone.Collection

  model: Coreon.Models.Hit

  findByResult: (result) ->
    for hit in @models
      return hit if hit.get("result") is result
    null
