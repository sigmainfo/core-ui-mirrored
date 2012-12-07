#= require environment
#= require d3

class Coreon.Views.Concepts.ConceptNodeView extends Backbone.View

  initialize: ->
    @model.on "change", @render, @

  render: () ->
    @clear()
    @svg.append("svg:rect")
      .attr("class", "background")
      .attr("width", 60)
      .attr("height", 19)

    @svg.append("svg:circle")
      .attr("cx", 7)
      .attr("cy", 10)
      .attr("r", 3)


    @svg.append("svg:text")
      .attr("x", 14)
      .attr("y", 14)
      .text(@model.label())

  setElement: (el, delegate) ->
    super el, delegate
    @svg = d3.select(@el).classed "concept-node", true

  clear: ->
    @svg.selectAll("*").remove()

  dissolve: ->
    @model.off null, null, @

  # remove: ->
  #   @svg.remove()

  destroy: ->
    @dissolve()
    # @remove()
