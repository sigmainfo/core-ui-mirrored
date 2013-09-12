#= require environment

class Coreon.Models.BroaderAndNarrowerForm extends Backbone.Model

  initialize: (attrs, opts={})->
    @concept = opts.concept
    @set "subconcept_ids", @concept.get("subconcept_ids")
    @set "superconcept_ids", @concept.get("superconcept_ids")
    @set "label", @concept.get("label")
    @set "id", @concept.id

    @on "change:subconcept_ids", (model, newValue)=>
      @set "subconcept_ids", _.uniq(newValue), silent: yes
    @on "change:superconcept_ids", (model, newValue)=>
      @set "superconcept_ids", _.uniq(newValue), silent: yes

  isNew: ->
    @concept.isNew()

  acceptsConnection: (ident)->
    checklist = [@id]
    checklist.push @get("superconcept_ids")...
    checklist.push @get("subconcept_ids")...
    !(ident in checklist)

  resetConceptConnections: ->
    @set "subconcept_ids", @concept.get("subconcept_ids")
    @set "superconcept_ids", @concept.get("superconcept_ids")

  _temporaryChanges: (toCompare, comparative)->
    {
      added: _.difference @get(toCompare), comparative
      removed: _.difference comparative, @get(toCompare)
    }

  addedBroaderConcepts: ->
    @_temporaryChanges("superconcept_ids", @concept.get("superconcept_ids")).added
  addedNarrowerConcepts: ->
    @_temporaryChanges("subconcept_ids", @concept.get("subconcept_ids")).added

  removedBroaderConcepts: ->
    @_temporaryChanges("superconcept_ids", @concept.get("superconcept_ids")).removed
  removedNarrowerConcepts: ->
    @_temporaryChanges("subconcept_ids", @concept.get("subconcept_ids")).removed

  save: (data, opts)->
    @concept.save data, opts

