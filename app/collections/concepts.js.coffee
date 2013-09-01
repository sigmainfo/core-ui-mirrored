#= require environment
# do not require models/concept here to avoid circular dependency

class Coreon.Collections.Concepts extends Backbone.Collection

  initialize: ->
    # set model here so that models/concept was already defined
    @model = Coreon.Models.Concept

    @on "add", @onAdd, @
    @on "remove", @onRemove, @
    @on "change:super_concept_ids", @onChangeSuperConceptIds, @
    @on "change:sub_concept_ids", @onChangeSubConceptIds, @

  onAdd: (model, collection, options) ->

    for super_concept_id in model.get "super_concept_ids"
      if parent = @get super_concept_id
        sub_concept_ids = (id for id in parent.get "sub_concept_ids")
        unless model.id in sub_concept_ids
          sub_concept_ids.push model.id
          parent.set "sub_concept_ids", sub_concept_ids, silent: yes

    for sub_concept_id in model.get "sub_concept_ids"
      if child = @get sub_concept_id
        super_concept_ids = (id for id in child.get "super_concept_ids")
        unless model.id in super_concept_ids
          super_concept_ids.push model.id
          child.set "super_concept_ids", super_concept_ids, silent: yes

  onRemove: (model, collection, options) ->
    
    for super_concept_id in model.get "super_concept_ids"
      if parent = @get super_concept_id
        sub_concept_ids =
          (id for id in parent.get "sub_concept_ids" when id isnt model.id)
        parent.set "sub_concept_ids", sub_concept_ids, silent: yes

    for sub_concept_id in model.get "sub_concept_ids"
      if child = @get sub_concept_id
        super_concept_ids =
          (id for id in child.get "super_concept_ids" when id isnt model.id)
        child.set "super_concept_ids", super_concept_ids, silent: yes

  onChangeSuperConceptIds: (model, value, options) ->

    previous = model.previous "super_concept_ids"
    removed  = (id for id in previous when id not in value)
    added    = (id for id in value when id not in previous)

    for super_concept_id in removed
      if parent = @get super_concept_id
        sub_concept_ids =
          (id for id in parent.get "sub_concept_ids" when id isnt model.id)
        parent.set "sub_concept_ids", sub_concept_ids, silent: yes

    for super_concept_id in added
      if parent = @get super_concept_id
        sub_concept_ids = (id for id in parent.get "sub_concept_ids")
        unless model.id in sub_concept_ids
          sub_concept_ids.push model.id
          parent.set "sub_concept_ids", sub_concept_ids, silent: yes

  onChangeSubConceptIds: (model, value, options) ->

    previous = model.previous "sub_concept_ids"
    removed  = (id for id in previous when id not in value)
    added    = (id for id in value when id not in previous)

    for sub_concept_id in removed
      if child = @get sub_concept_id
        super_concept_ids =
          (id for id in child.get "super_concept_ids" when id isnt model.id)
        child.set "super_concept_ids", super_concept_ids, silent: yes

    for sub_concept_id in added
      if child = @get sub_concept_id
        super_concept_ids = (id for id in child.get "super_concept_ids")
        unless model.id in super_concept_ids
          super_concept_ids.push model.id
          child.set "super_concept_ids", super_concept_ids, silent: yes
