#= require environment

window.requestAnimationFrame ?= window.webkitRequestAnimationFrame
window.cancelAnimationFrame ?= window.webkitCancelAnimationFrame

Coreon.Modules.Loop =

  startLoop: (callback) ->
    status = frame: 0
    @_loops ?= []
    @_loops.push status
    eachFrame = (now) =>
      status._currentHandle = requestAnimationFrame eachFrame
      status.start ?= now
      status.now = now
      status.duration = now - status.start
      status.frame += 1
      callback.call @, status
    status._currentHandle = requestAnimationFrame eachFrame
    status

  stopLoop: (status) ->
    if @_loops?
      @_loops = for current in @_loops
        if not status? or current is status
          cancelAnimationFrame current._currentHandle
          continue
        current
