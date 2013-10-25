#= require environment

class Coreon.Models.Repository extends Backbone.Model

  defaults: ->
    managers: []

  path: ->
    "/#{@id}"

