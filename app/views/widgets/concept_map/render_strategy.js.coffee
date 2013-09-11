#= require environment
#= require d3
#= require helpers/repository_path

class Coreon.Views.Widgets.ConceptMap.RenderStrategy

  constructor: (@parent) ->
    @layout = d3.layout.tree()
    @diagonal = d3.svg.diagonal()

  resize: (@width, @height) ->

  render: (tree) ->
    @renderNodes tree.root
    @renderEdges tree.edges

  renderNodes: (root) ->
    nodes = @parent.selectAll(".concept-node")
      .data( @layout.nodes(root)[1..], (datum) ->
        datum.id
      )
    @createNodes nodes.enter()
    @deleteNodes nodes.exit()
    @updateNodes nodes
    nodes

  createNodes: (enter) ->
    nodes = enter.append("g")
      .attr("class", "concept-node")

    nodes.append("title")

    links = nodes.append("a")
      .attr("xlink:href", (datum) ->
        if datum.id?
          Coreon.Helpers.repositoryPath "concepts/#{datum.id}"
        else
          "javascript:void(0)"
      )

    links.append("rect").attr("class", "background")
    links.append("circle").attr("class", "bullet")
    links.append("text").attr("class", "label")

    @createToggles nodes, "toggle-parents"
    @createToggles nodes, "toggle-children"

    nodes

  createToggles: (nodes, className) ->
    toggles = nodes.append("g")
      .attr("class", "toggle #{className}")

    toggles.append("rect")
      .attr("class", "background")
      .attr("width", 20)
      .attr("height", 20)
      .attr("x", -10)
      .attr("y", -10)
    toggles.append("path")
      .attr("class", "icon")
      .attr("d", "M -3.5 -2 h 7 m 0 4 h -7")
    toggles

  deleteNodes: (exit) ->
    exit.remove()

  updateNodes: (nodes) ->
    nodes
      .classed("hit", (datum) ->
        if datum.hit then "hit" else no
      )
      .classed("new", (datum) ->
        if datum.id then no else "new"
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
      .attr("filter", (datum) ->
        if datum.hit then "url(#coreon-drop-shadow-filter)" else null
      )

    nodes.select("g.toggle-parents")
      .attr("style", (datum) ->
        if datum.root then "display: none" else null
      )
      .classed("expanded", (datum) ->
        datum.expandedIn
      )

    nodes.select("g.toggle-children")
      .attr("style", (datum) ->
        if datum.leaf then "display: none" else null
      )
      .classed("expanded", (datum) ->
        datum.expandedOut
      )

    nodes

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
