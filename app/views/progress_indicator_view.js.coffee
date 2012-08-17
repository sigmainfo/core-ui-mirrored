#= require environment

class Coreon.Views.ProgressIndicatorView extends Backbone.View
  id: "coreon-progress-indicator"

  initialize: ->
    @collection.on "reset", @render, @
    @collection.on "remove", @render, @
    @collection.on "add", @start, @

  render: ->
    if @collection.length then @start() else @stop()
    @

  start: ->
    @busy = true
    @$el.removeClass "idle"
    @$el.addClass "busy"

  stop: ->
    @busy = false
    @$el.removeClass "busy"
    @$el.addClass "idle"

  destroy: (remove = false) ->
    @collection.off null, null, @
    @undelegateEvents()
    @remove() if remove
    @
