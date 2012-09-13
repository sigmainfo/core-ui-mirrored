#= require environment

class Coreon.Models.Search extends Backbone.Model

  defaults:
    hits: []

  url: ->
    @get "path"

  query: ->
    params = @get "params"
    qparams = if params["search[target]"]?
    then t: params["search[target]"]
    else {}
    qparams.q = params["search[query]"]
    $.param qparams

  sync: (method, model, options = {}) ->
    _(options).extend
      type: "POST"
      data: @get "params"
    Coreon.application.sync method, model, options
