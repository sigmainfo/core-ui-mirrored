#= require environment
#= require models/connection

class Coreon.Collections.Connections extends Backbone.Collection

  model: Coreon.Models.Connection

  destroy: ->
    model.get("xhr").abort() for model in @models
    @reset()
  
  sync: (method, model, options = {}) ->
    options.headers ?= {}
    options.headers["X-Core-Session"] = Coreon.application.account.get("session")
    jqXHR = Backbone.sync method, model, options
    @add xhr: jqXHR, method: method, model: model, options: options
    jqXHR
