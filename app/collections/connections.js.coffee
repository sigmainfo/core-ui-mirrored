#= require environment
#= require models/connection

class Coreon.Collections.Connections extends Backbone.Collection

  model: Coreon.Models.Connection

  destroy: ->
    model.get("xhr").abort() for model in @models
    @reset()
  
  sync: (method, model, options = {}) ->
    options.headers ?= {}
    options.headers["X-Core-Session"] = @session.get "token"
    options.url ?= @session.get("graph_root")[..-2] + _(model).result("url")
    plain = {}
    plain[key] = value for key, value of options
    jqXHR = Backbone.sync method, model, options
    @add xhr: jqXHR, method: method, model: model, options: plain
    jqXHR
