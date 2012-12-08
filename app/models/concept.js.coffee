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
    _.escape( @propLabel() or @termLabel() or @id )

  info: ->
    internals = _(@defaults).keys()
    internals.unshift @idAttribute
    _(id: @id).extend _(@attributes).omit internals

  hit: ->
    Coreon.application.hits.get(@id)?

  propLabel: ->
    _(@get "properties")?.find( (prop) -> prop.key is "label" )?.value

  termLabel: ->
    terms = @get "terms"
    label = null
    for term in terms
      if term.lang.match /^en/i
        label = term.value
        break
    label ||= terms?[0]?.value
    label

  sync: (method, model, options = {}) ->
    Coreon.application.sync method, model, options
