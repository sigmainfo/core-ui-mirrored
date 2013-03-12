#= require environment

class Coreon.Models.Hit extends Backbone.Model

  defaults:
    score: 0

  validate: ->
    "must have an id" unless @id?
