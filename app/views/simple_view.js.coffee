#= require environment

class Coreon.Views.SimpleView extends Backbone.View

  for method in ["appendTo", "prependTo", "insertAfter", "insertBefore"]
    do (method) ->
      SimpleView::[method] = (target) ->
        @$el[method] target
        @delegateEvents()
        @

  clear: ->
    @$el.empty()
    @

  dissolve: ->
    @model.off null, null, @ if @model
    @

  destroy: ->
    @remove()
    @dissolve()
