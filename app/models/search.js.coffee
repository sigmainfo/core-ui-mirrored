#= require environment

class Coreon.Models.Search extends Backbone.Model

  defaults:
    hits: []

  url: ->
    @get "path"

  sync: (method, model, options = {}) ->
    _(options).extend
      type: "POST"
      data: @get "params"
    Coreon.application.sync method, model, options
