#= require environment

class Coreon.Views.Layout.ProgressIndicatorView extends Coreon.Views.SimpleView
  id: "coreon-progress-indicator"

  animation:
    fps: 18
    frames: 36
    width: 30
    frame: 0

  initialize: ->
    @$el.css 
      width: @animation.width
      backgroundPosition: "0 0"

    @collection.on "reset", @render, @
    @collection.on "remove", @render, @
    @collection.on "add", @start, @

  render: ->
    if @collection.length then @start() else @stop()
    @

  start: ->
    unless @busy
      @busy = true
      @$el.addClass "busy"
      @animation.id = setInterval @next, 1000 / @animation.fps 

  stop: ->
    if @busy
      @busy = false
      @$el.removeClass "busy"
      clearInterval @animation.id
      delete @animation.id
      @animation.frame = 0
      @$el.css "backgroundPosition", "0 0"

  next: =>
    @animation.frame = ++@animation.frame % @animation.frames
    @$el.css "backgroundPosition", "-#{@animation.frame * @animation.width}px 0"

  destroy: (remove = false) ->
    @stop()
    @collection.off null, null, @
    @undelegateEvents()
    @remove() if remove
    @
