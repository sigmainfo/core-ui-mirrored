#= require environment

class Coreon.Models.Hit extends Backbone.Model

  defaults:
    score: 0
    model: null

  validate: ->
    "must have an id" unless @id?
