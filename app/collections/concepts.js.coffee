#= require environment
#= require models/concept 

class Coreon.Collections.Concepts extends Backbone.Collection

  model: Coreon.Models.Concept

  url: ->
    Coreon.application.account.get("graph_root") + "concepts"

  get: (id) ->
    unless super(id)?
      @add id: id
      super(id).fetch()
    super(id)

  sync: (method, model, options) ->
    if method is "read"
      options.type = "POST" 
      options.url = @url() + "/search"
    Coreon.application.account.connections.sync method, model, options
