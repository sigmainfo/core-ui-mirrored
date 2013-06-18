#= require environment

collection = null

class Coreon.Models.Notification extends Backbone.Model

  @collection = ->
    collection ?= new Backbone.Collection [], model: @

  @info = (message) ->
    @collection().add message: message

  @error = (message) ->
    @collection().add message: message, type: "error"

  defaults:
    message: ""
    type: "info"
