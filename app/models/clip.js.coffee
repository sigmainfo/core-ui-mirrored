#= require environment
#= require models/concept

class Coreon.Models.Clip extends Backbone.Model

  concept: null

  initialize: (@concept)->
    @id = @concept.id or @concept.cid
    @listenTo @concept, "all", @_onConceptChange

  _onConceptChange: (type, model, args...) ->
    @id = model.id or model.cid if type is "change:#{Coreon.Models.Concept::idAttribute}"
    @trigger type, @, args... if type.indexOf("change") is 0

