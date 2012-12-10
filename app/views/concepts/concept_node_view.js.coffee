#= require environment
#= require d3

class Coreon.Views.Concepts.ConceptNodeView extends Backbone.View

  initialize: ->
    @model.on "hit:add hit:remove", @toggleHit, @
    @model.on "change", @render, @

  render: () ->
    @clear()
    @toggleHit()

    a = @svg.append("svg:a")
      .attr("xlink:href", "/concepts/#{@model.id}")

    bg = a.append("svg:rect")
      .attr("class", "background")
      .attr("height", 19)

    a.append("svg:circle")
      .attr("cx", 7)
      .attr("cy", 10)
      .attr("r", 3)
    
    label = a.append("svg:text")
      .attr("x", 14)
      .attr("y", 14)
      .text(@abbreviate(@model.label()))

    box = label.node().getBBox()
    bg.attr("width", box.width + box.x + 3)
    
  abbreviate: (text) ->
    text = text[0..10] + "…" if text.length > 10
    text

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
