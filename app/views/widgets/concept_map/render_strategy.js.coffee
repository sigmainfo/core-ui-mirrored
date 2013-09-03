#= require environment
#= require d3

class Coreon.Views.Widgets.ConceptMap.RenderStrategy

  constructor: (@selection) ->
    @layout = d3.layout.tree()
    @diagonal = d3.svg.diagonal()

  resize: (@width, @height) ->

  render: (tree) ->
    @renderNodes tree.root
    @renderEdges tree.edges

  renderNodes: (root) ->

  renderEdges: (edges) ->
