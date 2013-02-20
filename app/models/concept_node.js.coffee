#= require environment
#= require models/concept

class Coreon.Models.ConceptNode extends Backbone.Model

  concept: null

  defaults: ->
    hit:  null
    expandedIn: false
    expandedOut: false
    subnodeIds: []
    supernodeIds: []

  initialize: (attributes = {}, options = {}) ->
    @concept = if options.concept?
      options.concept
    else if @id?
      Coreon.Models.Concept.find @id
    if @concept?
      @listenTo @concept, "all", @_onConceptChange
    @on "change:expandedOut change:sub_concept_ids", @_updateSubnodeIds, @
    @_updateSubnodeIds()
    @on "change:expandedIn change:super_concept_ids", @_updateSupernodeIds, @
    @_updateSupernodeIds()

  get: (attr) ->
    if @concept?.attributes.hasOwnProperty attr
      @concept.get attr
    else
      super attr

  _onConceptChange: (type, model, args...) ->
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
