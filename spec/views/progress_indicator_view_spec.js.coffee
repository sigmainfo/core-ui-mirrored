#= require spec_helper
#= require views/progress_indicator_view

describe "Coreon.Views.ProgressIndicatorView", ->

  beforeEach ->
    @view = new Coreon.Views.ProgressIndicatorView
      collection: new Backbone.Collection

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View
  
  it "creates container", ->
    @view.$el.should.have.id "coreon-progress-indicator"

  describe "#render", ->

    it "is chainable", ->
      @view.render().should.equal @view

    it "starts when busy", ->
      @view.start = sinon.spy()
      @view.collection.length = 3
      @view.render()
      @view.start.should.have.been.calledOnce

    it "stops when idle", ->
      @view.stop = sinon.spy()
      @view.collection.length = 0
      @view.render()
      @view.stop.should.have.been.calledOnce

    it "is triggered on reset", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.collection.trigger "reset"
      @view.render.should.have.been.calledOnce

    it "is triggered on remove", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.collection.trigger "remove"
      @view.render.should.have.been.calledOnce

  describe "#start", ->

    it "changes status", ->
      @view.busy = false
      @view.start()
      @view.busy.should.be.true

    it "marks view as being busy", ->
      @view.$el.addClass "idle"
      @view.$el.removeClass "busy"
      @view.start()
      @view.$el.should.not.have.class "idle"
      @view.$el.should.have.class "busy"

    it "is triggerd on add", ->
      @view.start = sinon.spy()
      @view.initialize()
      @view.collection.trigger "add"
      @view.start.should.have.been.calledOnce

    it "starts animation", ->
      @view.$el.sprite = sinon.spy()
      @view.start()
      @view.$el.sprite.should.have.been.calledWith
        fps: 24
        no_of_frames: 36
      
  describe "#stop", ->
    
    it "changes status", ->
      @view.busy = true
      @view.stop()
      @view.busy.should.be.false
    
    it "marks view as being idle", ->
      @view.start()
      @view.stop()
      @view.$el.should.have.class "idle"
      @view.$el.should.not.have.class "busy"

    it "stops animation", ->
      @view.$el.spStop = sinon.spy()
      @view.start()
      @view.stop()
      @view.$el.spStop.should.have.been.calledOnce
      

  describe "#destroy", ->

    it "is chainable", ->
      @view.destroy().should.equal @view

    it "dismisses collection", ->
      sinon.stub @view.collection
      @view.destroy()
      @view.collection.off.should.have.been.calledWith null, null, @view

    it "undelegates events", ->
      @view.undelegateEvents = sinon.spy()
      @view.destroy()
      @view.undelegateEvents.should.have.been.calledOnce

    it "keeps el by default", ->
      @view.remove = sinon.spy()
      @view.destroy()
      @view.remove.should.not.have.been.called
    
    it "can remove el", ->
      @view.remove = sinon.spy()
      @view.destroy(true)
      @view.remove.should.have.been.calledOnce

