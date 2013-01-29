#= require environment
#= require d3

class Coreon.Views.SVGView extends Backbone.View

  setElement: (el) ->
    super
    @svg = d3.select el
    @

  clear: ->
    @svg.selectAll("*").remove()
    @

  remove: ->
    @svg.remove()
    @stopListening()
    @
