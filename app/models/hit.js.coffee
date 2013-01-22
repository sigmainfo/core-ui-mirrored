#= require environment

class Coreon.Models.Hit extends Backbone.Model

  idAttribute: "id"

  defaults:
    score: 0
    expandChildren: false

  validate: ->
    "must have an id" unless @id?
