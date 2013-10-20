#= require environment
#= require d3
#= require helpers/repository_path

class Coreon.Views.Widgets.ConceptMap.RenderStrategy

  constructor: (@parent) ->
    @layout = d3.layout.tree()
    @diagonal = d3.svg.diagonal()

  resize: (@width, @height) ->

  render = (tree) ->
    nodes = @renderNodes tree.root
    edges = @renderEdges tree.edges
    _.defer @updateLayout, nodes, edges

  render: _.debounce render, 250

  renderNodes: (root) ->
    nodes = @parent.selectAll(".concept-node")
      .data( @layout.nodes(root), (datum) ->
        datum.id
      )
    @createNodes nodes.enter()
    @deleteNodes nodes.exit()
    @updateNodes nodes
    nodes

  createNodes: (enter) ->
    all = enter.append("g")
      .attr("class", "concept-node")
      .classed("repository-root", (datum) ->
        datum.type is "repository"
      )

    nodes = all.filter(
      (datum) -> datum.type isnt "placeholder"
    )

    nodes.append("title")

    links = nodes.append("a")
      .attr("xlink:href", (datum) ->
        switch
          when datum.type is "repository"
            Coreon.Helpers.repositoryPath()
          when datum.type is "concept" and datum.id?
            Coreon.Helpers.repositoryPath "concepts/#{datum.id}"
          else
            "javascript:void(0)"
      )
      .on("mouseover", (datum) ->
        d3.select(@).classed "hover", true
      )
      .on("mouseout", (datum) ->
        d3.select(@).classed "hover", false
      )
      .on("click", (datum) ->
        d3.select(@).classed "hover", false
      )

    links.append("rect").attr("class", "background")
    links.append("circle").attr("class", "bullet")
    links.append("text").attr("class", "label")

    placeholders = all.filter(
      (datum) -> datum.type is "placeholder"
    )

    placeholders.classed("placeholder", true)

    placeholders.append("circle")
      .attr("class", "background")

    placeholders.append("path")
      .attr("class", "icon")
      .attr("d", "M 0 -4 v 8 M -4 0 h 8")

    indicators = placeholders.append("g")
      .attr("class", "progress-indicator")

    indicators.append("circle")
      .attr("class", "track")
      .attr("r", "6")

    indicators.append("path")
      .attr("class", "cursor")
      .attr("d", "M 6 0 A 6 6 0 0 1 3 5.19")

    all

  deleteNodes: (exit) ->
    exit.each( (datum) =>
      if animation = datum.loop
        @parent.stopLoop animation
    )
    exit.remove()

  updateNodes: (all) ->
    all

    nodes = all.filter(
      (datum) -> datum.type isnt "placeholder"
    )

    nodes
      .classed("hit", (datum) ->
        datum.hit
      )
      .classed("parent-of-hit", (datum) ->
        datum.parent_of_hit
      )
      .classed("new", (datum) ->
        not datum.id?
      )
    
    nodes.select("title")
      .text( (datum) ->
        datum.label
      )

    nodes.select("circle.bullet")
      .attr("r", (datum) ->
        if datum.hit then 2.8 else 2.5
      )

    nodes.select("rect.background")
      .attr("rx", (datum) ->
        if datum.type is "repository" then 5 else null
      )
      .attr("filter", (datum) ->
        if datum.hit then "url(#coreon-drop-shadow-filter)" else null
      )

    placeholders = all.filter(
      (datum) -> datum.type is "placeholder"
    )

    placeholders.select("circle.background")
      .attr("r", (datum) ->
        if datum.parent.expanded then 10 else 7
      )

    placeholders.select("path.icon")
      .style("display", (datum) ->
        if datum.parent.expanded then "none" else null
      )

    placeholders.select("g.progress-indicator")
      .style("display", (datum) ->
        if datum.parent.expanded then null else "none"
      )

    parent = @parent
    placeholders.select("path.cursor")
      .each( (datum) ->
        if datum.parent.expanded
          cursor = d3.select @
          datum.loop ?= parent.startLoop (animation) ->
            cursor.attr("transform", ->
              "rotate(#{animation.duration * 0.4 % 360})"
            )     
        else
          parent.stopLoop datum.loop
      )

    all

  renderEdges: (edges) ->
    edges = @parent.selectAll(".concept-edge")
      .data(edges, (datum) ->
        "#{datum.source.id}|#{datum.target.id}"
      )
    @createEdges edges.enter()
    @deleteEdges edges.exit()
    @updateEdges edges
    edges

  createEdges: (enter) ->
    edges = enter.insert("path", ".concept-node")
      .attr("class", "concept-edge")
    edges

  deleteEdges: (exit) ->
    exit.remove()

  updateEdges: (edges) ->
    edges

  updateLayout: (nodes, edges) =>
    [nodes, edges]
