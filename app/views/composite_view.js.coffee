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
  
  for method in ["render", "delegateEvents", "undelegateEvents"]
    do (method) ->
      CompositeView::[method] = ->
        CompositeView.__super__[method].apply @, arguments
        subview[method].apply subview, arguments for subview in @subviews
        @

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

  remove: (subviews...) ->
    if subviews.length is 0
      super
    else
      for subview in subviews
        subview.remove() 
        @drop subview

  destroy: (subviews...) ->
    if subviews.length is 0
      subviews = @subviews
      super
    for subview in subviews
      subview.destroy()
      @drop subview

  clear: ->
    @destroy.apply @, @subviews if @subviews.length > 0
    super
