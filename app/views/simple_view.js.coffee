#= require environment

class Coreon.Views.SimpleView extends Backbone.View

  delegateEvents: (events) ->
    @_undelegated = false
    super(events)

  for method in ["appendTo", "prependTo", "insertAfter", "insertBefore"]
    do (method) ->
      SimpleView::[method] = (target) ->
        @$el[method] target
        @delegateEvents() if @_undelegated

  remove: ->
    @_undelegated = true
    super()

  dissolve: ->
    @model.off null, null, @ if @model
    @

  destroy: ->
    @remove()
    @dissolve()

