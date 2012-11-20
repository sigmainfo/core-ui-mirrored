#= require environment
#= require models/hit
#= require models/concept

class Coreon.Collections.Hits extends Backbone.Collection

  model: Coreon.Models.Hit

  initialize: ->
    @on "add", @_onAdd
    @on "remove", @_onRemove

  update: (hits = [], options = {}) ->
    updated = @_removeDropped hits, options
    updated ||= @_addMissing hits, options
    if updated and not options.silent?
      @trigger "hit:update", @, options

  _removeDropped: (hits, options) ->
    drops = []
    for model in @models
      keep = false
      for hit in hits
        if hit.id is model.id
          keep = true
          break
      drops.push model unless keep
    for drop in drops
      @remove drop, options
    drops.length > 0

  _addMissing: (hits, options) ->
    updated = false
    for hit in hits
      unless @get(hit.id)?
        @add [hit], options
        updated = true
    updated

  _onAdd: (model, collection, options) ->
    @_triggerEventOnConcept "add", model, collection, options

  _onRemove: (model, collection, options) ->
    @_triggerEventOnConcept "remove", model, collection, options

  _triggerEventOnConcept: (event, model, collection, options) ->
    concept = Coreon.Models.Concept.find model.id
    concept.trigger "hit:#{event}", model, collection, options
