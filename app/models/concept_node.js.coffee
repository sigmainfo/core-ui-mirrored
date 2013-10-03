#= require environment
#= require models/concept

class Coreon.Models.ConceptNode extends Backbone.Model

  defaults: ->
    concept: null
    expanded: no
  
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
    concept = super "concept"
    if concept?.attributes.hasOwnProperty attr
      concept.get attr
    else
      super attr

  triggerConceptChange: (type, model, args...) ->
    @id = args[0] if type is "change:id"
    @trigger type, @, args... if type.indexOf("change") is 0
