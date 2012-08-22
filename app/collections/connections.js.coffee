#= require environment

class Coreon.Collections.Connections extends Backbone.Collection

  sync: (method, model, options) ->
    jqXHR = Backbone.sync method, model, options
    @add xhr: jqXHR, method: method, model: model, options: options
    jqXHR

