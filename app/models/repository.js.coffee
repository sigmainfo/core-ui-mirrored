#= require environment

class Coreon.Models.Repository extends Backbone.Model

  idAttribute: "id"

  defaults: ->
    managers: []
    languages: []
