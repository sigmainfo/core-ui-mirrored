#= require environment

class Coreon.Models.Concept extends Backbone.Model

  defaults:
    properties: []

  label: ->
    @propLabel() or @termLabel() or @id

  propLabel: ->
    _(@get "properties")?.find( (prop) -> prop.key is "label" )?.value

  termLabel: ->
    @get("terms")?[0]?.value

  sync: (method, model, options = {}) ->
    Coreon.application.sync method, model, options
