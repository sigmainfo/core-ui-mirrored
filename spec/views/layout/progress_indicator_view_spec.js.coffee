#= require spec_helper
#= require views/layout/progress_indicator_view

describe "Coreon.Views.Layout.ProgressIndicatorView", ->

  beforeEach ->
    @time = sinon.useFakeTimers()
    @view = new Coreon.Views.Layout.ProgressIndicatorView
      collection: new Backbone.Collection

  afterEach ->
    @time.restore()
    @view.destroy()

  it "is a backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  describe "start()", ->

    it "is triggered on CoreAPI->start", ->
      @view.start = sinon.spy()
      @view.initialize()
      Coreon.Modules.CoreAPI.trigger "start"
      @view.start.should.have.been.calledOnce

    it "changes status", ->
      @view.busy = false
      @view.start()
      @view.busy.should.be.true

    it "marks view as being busy", ->
      @view.$el.removeClass "busy"
      @view.start()
      @view.$el.should.have.class "busy"

    it "starts animation", ->
      @view.start()
      @time.tick 2500
      @view.animation.frame.should.equal 8
      @view.$el.should.have.css "background-position", "-240px 0px"

  describe "stop()", ->

    beforeEach ->
      @view.start()
      @time.tick 500

    it "is triggered on CoreAPI->stop", ->
      @view.stop = sinon.spy()
      @view.initialize()
      Coreon.Modules.CoreAPI.trigger "stop"
      @view.stop.should.have.been.calledOnce

    it "changes status", ->
      @view.stop()
      @view.busy.should.be.false

    it "marks view as being idle", ->
      @view.stop()
      @view.$el.should.not.have.class "busy"

    it "stops animation", ->
      @view.stop()
      @time.tick 250
      @view.animation.frame.should.equal 0
      @view.$el.should.have.css "background-position", "0px 0px"
