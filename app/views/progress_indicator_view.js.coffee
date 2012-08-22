#= require environment
#= require jquery.spritely

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
    unless @busy
      @busy = true
      @$el.removeClass "idle"
      @$el.addClass "busy"
      @$el.sprite
        fps: 18
        no_of_frames: 36

  stop: ->
    if @busy
      @busy = false
      @$el.removeClass "busy"
      @$el.addClass "idle"
      @$el.spStop()

  destroy: (remove = false) ->
    @collection.off null, null, @
    @undelegateEvents()
    @remove() if remove
    @
