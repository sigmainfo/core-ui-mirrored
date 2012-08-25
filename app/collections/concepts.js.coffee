#= require environment

class Coreon.Collections.Concepts extends Backbone.Collection

  url: ->
    Coreon.application.account.get("graph_root") + "concepts"

  sync: (method, model, options) ->
    if method is "read"
      options.type = "POST" 
      options.url = @url() + "/search"
    Coreon.application.account.connections.sync method, model, options
