#= require spec_helper
#= require views/simple_view

describe "Coreon.Views.SimpleView", ->
  
  beforeEach ->
    @view = new Coreon.Views.SimpleView className: "simple"

  afterEach ->
    @view.destroy()

  it "is a backbone view", -> 
    @view.should.be.an.instanceof Backbone.View

  describe "#appendTo", ->
    
    it "appends el to target", ->
      @view.appendTo "#konacha"
      $("#konacha").should.have @view.$el

    it "delegates events", ->
      @view.delegateEvents = sinon.spy()
      @view.remove()
      @view.appendTo "#konacha"
      @view.delegateEvents.should.have.been.calledOnce

    it "delegates events only when necessary", ->
      @view.delegateEvents = sinon.spy()
      @view.appendTo "#konacha"
      @view.delegateEvents.should.not.have.been.called

    it "delegates events only once", ->
      sinon.spy @view, "delegateEvents"
      @view.remove()
      @view.delegateEvents()
      @view.appendTo "#konacha"
      @view.delegateEvents.should.have.been.calledOnce

  describe "#prependTo", ->
    
    it "prepends el to target", ->
      @view.prependTo "#konacha"
      $("#konacha").should.have @view.$el

    it "delegates events", ->
      @view.delegateEvents = sinon.spy()
      @view.remove()
      @view.prependTo "#konacha"
      @view.delegateEvents.should.have.been.calledOnce

    it "delegates events only when necessary", ->
      @view.delegateEvents = sinon.spy()
      @view.prependTo "#konacha"
      @view.delegateEvents.should.not.have.been.called

    it "delegates events only once", ->
      sinon.spy @view, "delegateEvents"
      @view.remove()
      @view.delegateEvents()
      @view.prependTo "#konacha"
      @view.delegateEvents.should.have.been.calledOnce

  describe "#insertAfter", ->

    beforeEach ->
      $("#konacha").append $("<div id='target'>")
    
    it "inserts el after target", ->
      @view.insertAfter "#target"
      $("#target").next().should.be @view.$el

    it "delegates events", ->
      @view.delegateEvents = sinon.spy()
      @view.remove()
      @view.insertAfter "#target"
      @view.delegateEvents.should.have.been.calledOnce

    it "delegates events only when necessary", ->
      @view.delegateEvents = sinon.spy()
      @view.insertAfter "#target"
      @view.delegateEvents.should.not.have.been.called

    it "delegates events only once", ->
      sinon.spy @view, "delegateEvents"
      @view.remove()
      @view.delegateEvents()
      @view.insertAfter "#target"
      @view.delegateEvents.should.have.been.calledOnce

  describe "#insertBefore", ->

    beforeEach ->
      $("#konacha").append $("<div id='target'>")
    
    it "inserts el before target", ->
      @view.insertBefore "#target"
      $("#target").prev().should.be @view.$el

    it "delegates events", ->
      @view.delegateEvents = sinon.spy()
      @view.remove()
      @view.insertBefore "#target"
      @view.delegateEvents.should.have.been.calledOnce

    it "delegates events only when necessary", ->
      @view.delegateEvents = sinon.spy()
      @view.insertBefore "#target"
      @view.delegateEvents.should.not.have.been.called

    it "delegates events only once", ->
      sinon.spy @view, "delegateEvents"
      @view.remove()
      @view.delegateEvents()
      @view.insertBefore "#target"
      @view.delegateEvents.should.have.been.calledOnce

  describe "#remove", ->
    
    it "can be chained", ->
      @view.remove().should.equal @view

    it "calls remove on el", ->
      @view.$el.remove = sinon.spy()
      @view.remove()
      @view.$el.remove.should.have.been.calledOnce

  describe "#dissolve", ->
    
    it "unbinds model", ->
      spy = sinon.spy()
      @view.model = new Backbone.Model
      @view.model.on "change", spy, @view
      @view.dissolve()
      @view.model.trigger "change"
      spy.should.not.have.been.called

    it "fails gracefully when no model is given", ->
      @view.model = null
      @view.dissolve()
      expect(=> @view.dissolve()).to.not.throw Error

    it "can be chained", ->
      @view.dissolve().should.equal @view
 
  describe "#destroy", ->
    
    it "removes view el", ->
      @view.remove = sinon.spy()
      @view.destroy()
      @view.remove.should.have.been.calledOnce

    it "dissolves view instance", ->
      @view.dissolve = sinon.spy()
      @view.destroy()
      @view.dissolve.should.have.been.calledOnce   
