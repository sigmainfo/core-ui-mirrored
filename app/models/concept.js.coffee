#= require environment

class Coreon.Models.Concept extends Backbone.Model

  defaults:
    properties: []

  label: ->
    label = _(@get "properties").find (prop) -> prop.key is "label"
    if label? then label.value else @id

  sync: (method, model, options = {}) ->
    Coreon.application.sync method, model, options
