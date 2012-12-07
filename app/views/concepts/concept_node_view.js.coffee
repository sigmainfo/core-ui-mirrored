#= require environment
#= require d3

class Coreon.Views.Concepts.ConceptNodeView extends Backbone.View

  initialize: ->
    @model.on "change", @render, @

  render: () ->
    @clear()
    @svg.append("text").text @model.label()

  setElement: (el, delegate) ->
    super el, delegate
    @svg = d3.select(@el).classed "concept-node", true

  clear: ->
    @svg.selectAll("*").remove()

  dissolve: ->
    @model.off null, null, @

  remove: ->
    @svg.remove()

  destroy: ->
    @dissolve()
    @remove()
