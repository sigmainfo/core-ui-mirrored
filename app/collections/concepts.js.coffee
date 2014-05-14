#= require environment
# do not require models/concept here to avoid circular dependency

class Coreon.Collections.Concepts extends Backbone.Collection

  initialize: ->
    # set model here so that models/concept was already defined
    @model = Coreon.Models.Concept

    @on "add", @onAdd, @
    @on "remove", @onRemove, @
    @on "change:superconcept_ids", @onChangeSuperConceptIds, @
    @on "change:subconcept_ids", @onChangeSubConceptIds, @

  onAdd: (model, collection, options) ->

    for superconcept_id in model.get "superconcept_ids"
      if parent = @get superconcept_id
        subconcept_ids = (id for id in parent.get "subconcept_ids")
        unless model.id in subconcept_ids
          subconcept_ids.push model.id
          parent.set "subconcept_ids", subconcept_ids, silent: yes

    for subconcept_id in model.get "subconcept_ids"
      if child = @get subconcept_id
        superconcept_ids = (id for id in child.get "superconcept_ids")
        unless model.id in superconcept_ids
          superconcept_ids.push model.id
          child.set "superconcept_ids", superconcept_ids, silent: yes

  onRemove: (model, collection, options) ->

    for superconcept_id in model.get "superconcept_ids"
      if parent = @get superconcept_id
        subconcept_ids =
          (id for id in parent.get "subconcept_ids" when id isnt model.id)
        parent.set "subconcept_ids", subconcept_ids, silent: yes

    for subconcept_id in model.get "subconcept_ids"
      if child = @get subconcept_id
        superconcept_ids =
          (id for id in child.get "superconcept_ids" when id isnt model.id)
        child.set "superconcept_ids", superconcept_ids, silent: yes

  onChangeSuperConceptIds: (model, value, options) ->

    previous = model.previous "superconcept_ids"
    removed  = (id for id in previous when id not in value)
    added    = (id for id in value when id not in previous)

    for superconcept_id in removed
      if parent = @get superconcept_id
        subconcept_ids =
          (id for id in parent.get "subconcept_ids" when id isnt model.id)
        parent.set "subconcept_ids", subconcept_ids, silent: yes

    for superconcept_id in added
      if parent = @get superconcept_id
        subconcept_ids = (id for id in parent.get "subconcept_ids")
        unless model.id in subconcept_ids
          subconcept_ids.push model.id
          parent.set "subconcept_ids", subconcept_ids, silent: yes

  onChangeSubConceptIds: (model, value, options) ->

    previous = model.previous "subconcept_ids"
    removed  = (id for id in previous when id not in value)
    added    = (id for id in value when id not in previous)

    for subconcept_id in removed
      if child = @get subconcept_id
        superconcept_ids =
          (id for id in child.get "superconcept_ids" when id isnt model.id)
        child.set "superconcept_ids", superconcept_ids, silent: yes

    for subconcept_id in added
      if child = @get subconcept_id
        superconcept_ids = (id for id in child.get "superconcept_ids")
        unless model.id in superconcept_ids
          superconcept_ids.push model.id
          child.set "superconcept_ids", superconcept_ids, silent: yes
