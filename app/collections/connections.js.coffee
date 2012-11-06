#= require environment
#= require models/connection

class Coreon.Collections.Connections extends Backbone.Collection

  model: Coreon.Models.Connection

  destroy: ->
    model.get("xhr").abort() for model in @models
    @reset()
  
  sync: (method, model, options = {}) ->
    _(options.headers ?= {}).extend "X-Core-Session": @account.get "session"
    options.url ?= @account.get("graph_root") + _(model).result("url")
    jqXHR = Backbone.sync method, model, options
    @add xhr: jqXHR, method: method, model: model, options: options
    jqXHR
