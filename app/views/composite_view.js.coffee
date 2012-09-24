#= require environment
#= require views/simple_view

class Coreon.Views.CompositeView extends Coreon.Views.SimpleView 

  initialize: ->
    super
    @subviews = []

  add: (views...) ->
    @subviews = _(@subviews).union views

  drop: (views...) ->
    @subviews = _(@subviews).difference views
  
  for method in ["render", "delegateEvents", "undelegateEvents", "destroy"]
    do (method) ->
      CompositeView::[method] = ->
        subview[method].apply subview, arguments for subview in @subviews
        CompositeView.__super__[method].apply @, arguments

  for method in ["append", "prepend"]
    do (method) ->
      CompositeView::[method] = (selector, views...) ->
        if typeof selector is "string"
          collection = @$ selector
          collection[method].apply collection, _(views).pluck "$el"
        else
          views.unshift selector
          @$el[method].apply @$el, _(views).pluck "$el"

        @add.apply @, views
        view.delegateEvents() for view in views

  clear: ->
    subview.destroy() for subview in @subviews
    @subviews = []
    super
    @
