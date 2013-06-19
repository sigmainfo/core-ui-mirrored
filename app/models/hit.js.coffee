#= require environment

collection = null

class Coreon.Models.Hit extends Backbone.Model

  @collection = ->
    collection ?= new Coreon.Collections.Hits 

  defaults:
    score: 0
    result: null
