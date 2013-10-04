#= require environment
#= require models/concept

class Coreon.Models.ConceptNode extends Backbone.Model

  defaults: ->
    concept: null
    expanded: no
    parent_of_hit: no
  
  initialize: ->
    @stopListening()
    @on "change:concept", @initConcept, @
    @initConcept()

  initConcept: ->
    @stopListening previous if previous = @previous "concept"
    if concept = @get "concept"
      @id = concept.id
      @listenTo concept, "all", @triggerConceptChange

  get: (attr) ->
    if @attributes.hasOwnProperty attr
      @attributes[attr]
    else if concept = @attributes.concept
      concept.get attr

  triggerConceptChange: (type, model, args...) ->
    @id = args[0] if type is "change:id"
    @trigger type, @, args... if type.indexOf("change") is 0
