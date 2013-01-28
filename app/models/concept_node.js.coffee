#= require environment
#= require models/concept

class Coreon.Models.ConceptNode extends Backbone.Model

  idAttribute: "id"

  concept: null

  defaults:
    hit:  null
    parentsExpanded: false
    childrenExpanded: false

  initialize: (attributes = {}, options = {}) ->
    @concept = if options.concept?
      options.concept
    else if attributes.id?
      Coreon.Models.Concept.find attributes.id
    if @concept?
      @listenTo @concept, "all", @trigger

  get: (attr) ->
    if @concept?.attributes.hasOwnProperty attr
      @concept.get attr
    else
      super attr
