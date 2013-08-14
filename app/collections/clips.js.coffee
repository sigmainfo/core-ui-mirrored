#= require environment

collection = null

class Coreon.Collections.Clips extends Backbone.Collection

  @collection: ->
    collection ?= new @
