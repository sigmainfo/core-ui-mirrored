#= require environment
#= require modules/accumulation

class Coreon.Models.Concept extends Backbone.Model

  _(@).extend Coreon.Modules.Accumulation

  urlRoot: "concepts"

  defaults:
    properties: []
    terms: []
    super_concept_ids: []
    sub_concept_ids: []

  label: ->
    @propLabel() or @termLabel() or @id

  info: ->
    internals = _(@defaults).keys()
    internals.unshift @idAttribute
    _(id: @id).extend _(@attributes).omit internals

  propLabel: ->
    _(@get "properties")?.find( (prop) -> prop.key is "label" )?.value

  termLabel: ->
    @get("terms")?[0]?.value

  sync: (method, model, options = {}) ->
    Coreon.application.sync method, model, options
