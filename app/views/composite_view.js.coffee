#= require environment
#= require views/simple_view

class Coreon.Views.CompositeView extends Coreon.Views.SimpleView 

  initialize: ->
    super()
    @subviews = []
  
  for method in ["render", "delegateEvents", "undelegateEvents", "destroy"]
    do (method) ->
      CompositeView::[method] = ->
        subview[method].apply subview, arguments for subview in @subviews
        CompositeView.__super__[method].apply @, arguments
        @

  for method in ["append", "prepend"]
    do (method) ->
      CompositeView::[method] = (view) ->
        @subviews.push view
        @$el[method] view.$el
        view.delegateEvents()

  clear: ->
    subview.destroy() for subview in @subviews
    super()
    @
