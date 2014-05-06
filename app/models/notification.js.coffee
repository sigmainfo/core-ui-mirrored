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
    hidden: false
    message: ""
    type: "info"

  initialize: ->
    clearTimeout @timeout
    @timeout = setTimeout ( => @destroy() ), 5000

  destroy: ->
    clearTimeout @timeout
    super
