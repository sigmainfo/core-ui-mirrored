#= require environment
#= require views/simple_view

class Coreon.Views.CompositeView extends Coreon.Views.SimpleView 

  initialize: ->
    @subviews = []
  
  for method in ["render", "delegateEvents", "undelegateEvents", "destroy"]
    do (method) ->
      CompositeView::[method] = (recursive = true) ->
        subview[method]() for subview in @subviews if recursive
        @

  for method in ["append", "prepend"]
    do (method) ->
      CompositeView::[method] = (view) ->
        @subviews.push view
        @$el[method] view.$el
        view.delegateEvents()
