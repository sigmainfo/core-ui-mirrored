#= require environment

class Coreon.Collections.Concepts extends Backbone.Collection

  sync: (method, model, options) ->
    if method is "read"
      options.type = "POST" 
      options.url = "#{@url}/search"
    Coreon.application.connections.sync method, model, options
