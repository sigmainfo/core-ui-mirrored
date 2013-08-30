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
    for super_concept_id in model.get("super_concept_ids")
      if parent = @get super_concept_id
        sub_concept_ids = parent.get("sub_concept_ids")
        unless model.id in sub_concept_ids
          sub_concept_ids.push model.id
          parent.set "sub_concept_ids", sub_concept_ids

  onRemove: (model, collection, options) ->
    for super_concept_id in model.get("super_concept_ids")
      @remove super_concept_id, silent: on
    for sub_concept_id in model.get("sub_concept_ids")
      @remove sub_concept_id, silent: on

  onChangeSuperConceptIds: (model, collection, options) ->
    for super_concept_id in model.get("super_concept_ids")
      @remove super_concept_id, silent: on

  onChangeSubConceptIds: (model, collection, options) ->
    for sub_concept_id in model.get("sub_concept_ids")
      @remove sub_concept_id, silent: on
