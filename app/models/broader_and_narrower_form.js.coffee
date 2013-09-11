#= require environment

class Coreon.Models.BroaderAndNarrowerForm extends Backbone.Model

  initialize: (attrs, opts={})->
    @concept = opts.concept
    @set "sub_concept_ids", @concept.get("sub_concept_ids")
    @set "super_concept_ids", @concept.get("super_concept_ids")
    @set "label", @concept.get("label")
    @set "_id", @concept.id

    @on "change:sub_concept_ids", (model, newValue)=>
      @set "sub_concept_ids", _.uniq(newValue), silent: yes
    @on "change:super_concept_ids", (model, newValue)=>
      @set "super_concept_ids", _.uniq(newValue), silent: yes

  isNew: ->
    @concept.isNew()

  acceptsConnection: (ident)->
    checklist = [@id]
    checklist.push @get("super_concept_ids")...
    checklist.push @get("sub_concept_ids")...
    !(ident in checklist)

  resetConceptConnections: ->
    @set "sub_concept_ids", @concept.get("sub_concept_ids")
    @set "super_concept_ids", @concept.get("super_concept_ids")

  _temporaryChanges: (toCompare, comparative)->
    {
      added: _.difference @get(toCompare), comparative
      removed: _.difference comparative, @get(toCompare)
    }

  save: (data, opts)->
    @concept.save data, opts

