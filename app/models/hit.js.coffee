#= require environment

class Coreon.Models.Hit extends Backbone.Model

  idAttribute: "id"

  defaults:
    score: 0

  validate: ->
    "must have an id" unless @id?
