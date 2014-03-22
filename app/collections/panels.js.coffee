#= require environment
#= require models/panel

class Coreon.Collections.Panels extends Backbone.Collection

  @instance = ->
    @_instance ?= new @ [
      { type: 'concepts', widget: off }
      { type: 'conceptMap' }
      { type: 'termList' }
    ]

  model: Coreon.Models.Panel
