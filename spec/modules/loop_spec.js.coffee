#= require spec_helper
#= require modules/helpers
#= require modules/loop

describe "Coreon.Modules.Loop", ->

  before ->
    unless window.requestAnimationFrame?
      @no_rAF = yes
      window.requestAnimationFrame = ->
      window.cancelAnimationFrame = ->
    class Coreon.Views.ViewWithLoop extends Backbone.View
      Coreon.Modules.include @, Coreon.Modules.Loop

  after ->
    delete Coreon.Views.ViewWithLoop
    if @no_rAF
      delete window.requestAnimationFrame
      delete window.cancelAnimationFrame

  beforeEach ->
    frame = []
    id = 0
    sinon.stub window, "requestAnimationFrame", (callback) ->
      id += 1
      frame.push callback
      callback.id = id

    cancelled = []
    sinon.stub window, "cancelAnimationFrame", (id) ->
      cancelled.push id

    @nextFrame = (now = Date.now) ->
      callbacks = (callback for callback in frame when callback.id not in cancelled)
      frame = []
      callback now for callback in callbacks

    @view = new Coreon.Views.ViewWithLoop

  afterEach ->
    window.requestAnimationFrame.restore()
    window.cancelAnimationFrame.restore()

  describe "startLoop()", ->

    it "does not trigger callback immediately", ->
      spy = sinon.spy()
      @view.startLoop spy
      spy.should.not.have.been.called

    it "triggers callback on next frame", ->
      spy = sinon.spy()
      @view.startLoop spy
      @nextFrame()
      spy.should.have.been.calledOnce

    it "keeps triggering callback on subsequent frames", ->
      spy = sinon.spy()
      @view.startLoop spy
      @nextFrame()
      @nextFrame()
      @nextFrame()
      spy.should.have.been.calledThrice

    it "binds callback to instance", ->
      spy = sinon.spy()
      @view.startLoop spy
      @nextFrame()
      spy.should.have.been.calledOn @view

    it "passes loop status to callback", ->
      spy = sinon.spy()
      @view.startLoop spy
      @nextFrame 34567
      @nextFrame 34589
      status = spy.secondCall.args[0]
      status.should.have.property "start", 34567
      status.should.have.property "now", 34589
      status.should.have.property "duration", 22
      status.should.have.property "frame", 2

    it "returns loop status", ->
      spy = sinon.spy()
      status = @view.startLoop spy
      @nextFrame()
      spy.should.have.been.calledWith status

    it "allows status to accumulate custom data", ->
      draw = (status) ->
        status.angle ?= 0
        status.angle += 10
      status = @view.startLoop draw
      @nextFrame()
      @nextFrame()
      @nextFrame()
      status.should.have.property "angle", 30

  describe "stopLoop()", ->

    it "stops triggering callback with given handle", ->
      spy = sinon.spy()
      status = @view.startLoop spy
      @view.stopLoop status
      @nextFrame()
      spy.should.not.have.been.called

    it "stops all loops when no handle is specified", ->
      spy = sinon.spy()
      @view.startLoop spy
      @view.startLoop spy
      @view.startLoop spy
      @view.stopLoop()
      @nextFrame()
      spy.should.not.have.been.called
