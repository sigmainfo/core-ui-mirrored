#= require environment
#= require d3

class Coreon.Views.Concepts.ConceptNodeView extends Backbone.View

  initialize: ->
    @model.on "hit:add hit:remove", @toggleHit, @
    @model.on "change", @render, @

  render: () ->
    @clear()
    @toggleHit()

    bg = @svg.append("svg:rect")
      .attr("class", "background")
      .attr("height", 19)

    @svg.append("svg:circle")
      .attr("cx", 7)
      .attr("cy", 10)
      .attr("r", 3)

    label = @svg.append("svg:text")
      .attr("x", 14)
      .attr("y", 14)
      .text(@model.label())

    box = label.node().getBBox()
    bg.attr("width", box.width + box.x + 3)
    


  setElement: (el, delegate) ->
    super el, delegate
    @svg = d3.select(@el).classed "concept-node", true

  toggleHit: ->
    @svg.classed "hit", @model.hit()

  clear: ->
    @svg.selectAll("*").remove()

  dissolve: ->
    @model.off null, null, @

  remove: ->
    @svg.remove()

  destroy: ->
    @dissolve()
    @remove()
