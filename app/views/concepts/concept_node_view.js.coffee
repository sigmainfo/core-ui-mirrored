#= require environment
#= require views/svg_view
#= require modules/helpers
#= require helpers/text

class Coreon.Views.Concepts.ConceptNodeView extends Coreon.Views.SVGView

  Coreon.Modules.include @, Coreon.Helpers.Text

  initialize: ->
    @listenTo @model, "change", @render

  render: ->
    @clear()

    @svg.classed "hit", @model.has "hit"

    a = @svg.append("svg:a")
      .attr("xlink:href", "/concepts/#{@model.id}")

    @bg = a.append("svg:rect")
      .attr("class", "background")
      .attr("height", 17)

    a.append("svg:circle")
      .attr("class", "bullet")
      .attr("cx", 7)
      .attr("cy", 9)
      .attr("r", 2.5)

    label = a.append("svg:text")
      .attr("x", 14)
      .attr("y", 13)
      .text(@shorten @model.get("label"))
    
    labelBox = label.node().getBBox()
    @bg.attr("width", labelBox.x + labelBox.width + 3)

    @

  box: ->
    if @bg? then @bg.node().getBBox() else x: 0, y: 0, height: 0, width: 0


  #   @toggleHit()

  #   bgBox = bg.node().getBBox()
  #   if @model.get("sub_concept_ids").length > 0
  #     @renderToggle("toggle-children", bgBox.height, bgBox.width, not @options.treeLeaf)
  #       .on("click", (d) => @trigger "toggle:children", d)
  #   if @model.get("super_concept_ids").length > 0
  #     @renderToggle("toggle-parents", bgBox.height, -bgBox.height, not @options.treeRoot)
  #       .on("click", (d) => @trigger "toggle:parents", d)


  # renderToggle: (name, size, pos, expanded) ->
  #   r = 3
  #   w = 7

  #   className = "toggle #{name}"
  #   className = className + " expanded" if expanded

  #   toggle = @svg.append("svg:g")
  #     .attr("class", className)
  #     .attr("transform", "translate(#{pos}, 0)")

  #   bg = toggle.append("svg:path")
  #     .attr("d", "m 0 0 l #{size - r} 0 a #{r} #{r} 0 0 1 #{r} #{r} l 0 #{size - 2 * r} a #{r} #{r} 0 0 1 #{-r} #{r} l #{r - size} 0 z")
  #     
  #   bg.attr("transform", "rotate(180, #{size / 2}, #{size / 2})") if pos < 0

  #   icon = toggle.append("svg:path")
  #     .attr("class", "icon")
  #     .attr("d", "M #{(size - w) / 2 } 7 l #{w} 0 m 0 3.5 l #{-w} 0")

  #   icon.attr("transform", "rotate(90, #{size / 2}, #{size / 2})") if expanded
  #   
  #   toggle
  #   

  # toggleHit: ->
  #   @svg.classed "hit", @model.hit()

  # onToggleParents: =>
  #   @trigger "toggle:parent"
