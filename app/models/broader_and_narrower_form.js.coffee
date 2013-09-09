#= require environment

class Coreon.Models.BroaderAndNarrowerForm extends Backbone.Model

  initialize: (@concept)->
    @set "concept_id", @concept.id
    @set "sub_concept_ids", @concept.get("sub_concept_ids")
    @set "super_concept_ids", @concept.get("super_concept_ids")
    @set "label", @concept.get("label")
    @set "_id", @concept.id

    @concept.on "change:sub_concept_ids", @updateSubconceptIds, @
    @concept.on "change:super_concept_ids", @updateSuperconceptIds, @
    @concept.on "change:label", => @set "label", @concept.get("label")
    @on "change:sub_concept_ids", (model, newValue)=>
      @set "sub_concept_ids", _.uniq(newValue), silent: yes
    @on "change:super_concept_ids", (model, newValue)=>
      @set "super_concept_ids", _.uniq(newValue), silent: yes

  isNew: ->
    @concept.isNew()

  updateSubconceptIds: (model, newIds)->
    changes = @_temporaryChanges "sub_concept_ids", model.previous "sub_concept_ids"
    newIds.push changes.added...
    newIds.unshift changes.removed...
    @set "sub_concept_ids", newIds

  updateSuperconceptIds: (model, newIds)->
    changes = @_temporaryChanges "super_concept_ids", model.previous "super_concept_ids"
    newIds.push changes.added...
    newIds.unshift changes.removed...
    @set "super_concept_ids", newIds

  acceptsConnection: (ident)->
    @concept.acceptsConnection(ident)

  _temporaryChanges: (toCompare, comparative)->
    {
      added: _.difference @get(toCompare), comparative
      removed: _.difference comparative, @get(toCompare)
    }

