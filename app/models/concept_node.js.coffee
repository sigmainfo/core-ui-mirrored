#= require environment
#= require models/concept

class Coreon.Models.ConceptNode extends Backbone.Model

  concept: null

  defaults:
    hit:  null
    expandedIn: false
    expandedOut: false

  initialize: (attributes = {}, options = {}) ->
    @concept = if options.concept?
      options.concept
    else if attributes.id?
      Coreon.Models.Concept.find attributes.id
    if @concept?
      @listenTo @concept, "all", @_onConceptChange

  get: (attr) ->
    if @concept?.attributes.hasOwnProperty attr
      @concept.get attr
    else
      super attr

  _onConceptChange: (type, model, args...) ->
    @trigger type, @, args... if type.indexOf("change") is 0
