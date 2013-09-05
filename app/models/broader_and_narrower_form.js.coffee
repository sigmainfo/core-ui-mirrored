#= require environment

class Coreon.Models.BroaderAndNarrowerForm extends Backbone.Model

  defaults: ->
    concept_id: null
    added_broader_relations: []
    added_narrower_relations: []
    deleted_broader_relations: []
    deleted_narrower_relations: []

  initialize: (@concept)->
    @set "concept_id", @concept.id
    @set "sub_concept_ids", @concept.get("sub_concept_ids")
    @set "super_concept_ids", @concept.get("super_concept_ids")
    @set "label", @concept.get("label")

    @concept.on "change:sub_concept_ids", =>
      @set "sub_concept_ids", @concept.get("sub_concept_ids")
    @concept.on "change:super_concept_ids", =>
      @set "super_concept_ids", @concept.get("super_concept_ids")
    @concept.on "change:label", =>
      @set "label", @concept.get("label")

  isNew: ->
    @concept.isNew()
