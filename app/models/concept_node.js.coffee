#= require environment
#= require models/concept

class Coreon.Models.ConceptNode extends Backbone.Model

  defaults: ->
    concept: null
    expanded: no
    parent_of_hit: no
    loaded: yes
  
  initialize: ->
    @stopListening()
    @on "change:concept", @initConcept, @
    @initConcept @get("concept"), silent: yes

  initConcept: (concept, options = {}) ->
    @stopListening previous if previous = @previous "concept"
    if concept?
      @set {
        id: concept.id
        loaded: not concept.blank
      }, options
      @listenTo concept, "all", @handleConceptEvent

  get: (attr) ->
    if @attributes.hasOwnProperty attr
      @attributes[attr]
    else if concept = @attributes.concept
      concept.get attr

  handleConceptEvent: (type, model, args...) ->
    switch
      when type.indexOf("change") is 0
        @set "id", model.id, silent: yes if type is "change:id"
        @trigger type, @, args...
      when type is "nonblank"
        @set "loaded", yes
