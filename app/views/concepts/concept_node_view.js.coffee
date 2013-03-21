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
    default:
      height: 16
      radius: 2.5
    hit:
      height: 18
      radius: 3
    dropShadow:
      offset: 1
  
  initialize: ->
    @listenTo @model, "change", @render

  render: ->
    @clear()

    @svg.classed "hit", @model.has "hit"
    @svg.classed "new", @model.isNew()
    
    title = @svg.append("svg:title")
      .text(@model.get "label")

    a = @svg.append("svg:a")
      .attr("xlink:href", (datum) =>
        if @model.isNew()
          "javascript:void(0)"
        else
          "/concepts/#{@model.id}"
      )

    @bg = a.append("svg:rect")
      .attr("class", "background")
      .attr("height", @height() )

    a.append("svg:circle")
      .attr("class", "bullet")
      .attr("cx", 7)
      .attr("cy", @height() / 2)
      .attr("r", @radius())
    
    unless @model.get("label")
      console.log JSON.stringify @model

    label = a.append("svg:text")
      .attr("x", 14)
      .attr("y", @height() * 0.75 )
      .text(@shorten @model.get("label"), 20)
    
    labelBox = label.node().getBBox()
    @bg.attr("width", labelBox.x + labelBox.width + 5)

    box = @box()

    if @model.has "hit"
      @bg.attr("filter", "url(#coreon-drop-shadow-filter)")

    if @model.get("sub_concept_ids")?.length > 0
      @_renderToggle(@model.get "expandedOut")
        .classed("toggle-children", true)
        .attr("transform", "translate(#{box.width}, 0)")
        .on("click", (datum) => @toggleChildren() )

    if @model.get("super_concept_ids")?.length > 0
      @_renderToggle(@model.get "expandedIn")
        .classed("toggle-parents", true)
        .attr("transform", "translate(0, #{box.height}) rotate(180)")
        .on("click", (datum) => @toggleParents() )
    @

  box: ->
    if @bg? then @bg.node().getBBox() else x: 0, y: 0, height: 0, width: 0

  height: ->
    if @model.has "hit" then @options.hit.height else @options.default.height

  radius: ->
    if @model.has "hit" then @options.hit.radius else @options.default.radius



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

  toggleParents: ->
    @model.set "expandedIn", not @model.get "expandedIn"
