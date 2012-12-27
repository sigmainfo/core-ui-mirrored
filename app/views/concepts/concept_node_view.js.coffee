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
      .attr("height", 17)

    a.append("svg:circle")
      .attr("cx", 7)
      .attr("cy", 9)
      .attr("r", 2.5)
    
    label = a.append("svg:text")
      .attr("x", 14)
      .attr("y", 13)
      .text(@abbreviate(@model.label()))

    textBox = label.node().getBBox()
    bg.attr("width", textBox.width + textBox.x + 3)

    bgBox = bg.node().getBBox()
    if @model.get("sub_concept_ids").length > 0
      @renderToggle("toggle-children", bgBox.height, bgBox.width, not @options.treeLeaf)
        .on("click", (d) => @trigger "toggle:children", d)
    if @model.get("super_concept_ids").length > 0
      @renderToggle("toggle-parents", bgBox.height, -bgBox.height, not @options.treeRoot)
        .on("click", (d) => @trigger "toggle:parents", d)


  renderToggle: (name, size, pos, expanded) ->
    r = 3
    w = 7

    className = "toggle #{name}"
    className = className + " expanded" if expanded

    toggle = @svg.append("svg:g")
      .attr("class", className)
      .attr("transform", "translate(#{pos}, 0)")

    bg = toggle.append("svg:path")
      .attr("d", "m 0 0 l #{size - r} 0 a #{r} #{r} 0 0 1 #{r} #{r} l 0 #{size - 2 * r} a #{r} #{r} 0 0 1 #{-r} #{r} l #{r - size} 0 z")
      
    bg.attr("transform", "rotate(180, #{size / 2}, #{size / 2})") if pos < 0

    icon = toggle.append("svg:path")
      .attr("class", "icon")
      .attr("d", "M #{(size - w) / 2 } 7 l #{w} 0 m 0 3.5 l #{-w} 0")

    icon.attr("transform", "rotate(90, #{size / 2}, #{size / 2})") if expanded
    
    toggle
    
  abbreviate: (text) ->
    text = text[0..10] + "…" if text.length > 10
    text

  setElement: (el, delegate) ->
    super el, delegate
    @svg = d3.select(@el).classed "concept-node", true

  toggleHit: ->
    @svg.classed "hit", @model.hit()

  onToggleParents: =>
    @trigger "toggle:parent"

  clear: ->
    @svg.selectAll("*").remove()

  dissolve: ->
    @model.off null, null, @

  remove: ->
    @svg.remove()

  destroy: ->
    @dissolve()
    @remove()
