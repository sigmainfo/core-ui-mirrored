#= require environment
#= require views/svg_view
#= require modules/helpers
#= require helpers/text

class Coreon.Views.Concepts.ConceptNodeView extends Coreon.Views.SVGView

  Coreon.Modules.include @, Coreon.Helpers.Text

  options:
    toggle:
      cornerRadius: 3
      iconWidth: 7
  
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

    box = @box()
    if @model.get("sub_concept_ids")?.length > 0
      @_renderToggle(@model.get "expandedOut")
        .classed("toggle-children", true)
        .attr("transform", "translate(#{box.width}, 0)")
        .on("click", (datum) => @toggleChildren() )

    if @model.get("super_concept_ids")?.length > 0
      @_renderToggle(@model.get "expandedIn")
        .classed("toggle-parents", true)
        .attr("transform", "translate(0, #{box.height}) rotate(180)")
    @

  box: ->
    if @bg? then @bg.node().getBBox() else x: 0, y: 0, height: 0, width: 0

  _renderToggle: (expanded) ->
    toggle = @svg.append("svg:g")
      .attr("class", "toggle")
      .classed("expanded", expanded)

    s = @box().height
    r = @options.toggle.cornerRadius
    w = @options.toggle.iconWidth

    bg = toggle.append("svg:path")
      .attr("class", "bg")
      .attr("d", "m 0 0 l #{s - r} 0 a #{r} #{r} 0 0 1 #{r} #{r} l 0 #{s - 2 * r} a #{r} #{r} 0 0 1 #{-r} #{r} l #{r - s} 0 z")
      
    icon = toggle.append("svg:path")
      .attr("class", "icon")
      .attr("d", "M #{(s - w) / 2 } 7 l #{w} 0 m 0 3.5 l #{-w} 0")

    icon.attr("transform", "rotate(90, #{s / 2}, #{s / 2})") if expanded
    
    toggle

  toggleChildren: ->
    @model.set "expandedOut", not @model.get "expandedOut"
