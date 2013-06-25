#= require environment
#= require models/concept

class Coreon.Models.ConceptNode extends Backbone.Model

  concept: null

  defaults: ->
    hit:  null
    concept: null
    expandedIn: false
    expandedOut: false
    subnodeIds: []
    supernodeIds: []

  initialize: (attributes = {}, options = {}) ->
    @stopListening()
    @set "concept", Coreon.Models.Concept.find(@id), silent: true unless @has "concept"
    @on "change:concept", @_updateConcept, @
    @_updateConcept()
    @on "change:expandedOut change:sub_concept_ids", @_updateSubnodeIds, @
    @_updateSubnodeIds()
    @on "change:expandedIn change:super_concept_ids", @_updateSupernodeIds, @
    @_updateSupernodeIds()

  get: (attr) ->
    concept = super "concept"
    if concept?.attributes.hasOwnProperty attr
      concept.get attr
    else
      super attr

  _onConceptChange: (type, model, args...) ->
    @id = model.id or model.cid if type is "change:#{Coreon.Models.Concept::idAttribute}"
    @trigger type, @, args... if type.indexOf("change") is 0

  _updateSubnodeIds: (model, value, options) ->
    newValue = if @get "expandedOut"
      @get("sub_concept_ids")?[..] ? []
    else
      []
    @set "subnodeIds", newValue, options

  _updateSupernodeIds: (model, value, options) ->
    newValue = if @get "expandedIn"
      @get("super_concept_ids")?[..] ? []
    else
      []
    @set "supernodeIds", newValue, options

  _updateConcept: ->
    if concept = @get "concept"
      @id = concept.id or concept.cid
      @listenTo concept, "all", @_onConceptChange if concept
    @stopListening previous if previous = @previous "concept"