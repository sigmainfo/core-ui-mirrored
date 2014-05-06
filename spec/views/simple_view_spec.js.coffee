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
      @view.delegateEvents = @spy()
      @view.remove()
      @view.appendTo "#konacha"
      @view.delegateEvents.should.have.been.calledOnce

    it "can be chained", ->
      @view.appendTo("#konacha").should.equal @view

  describe "#prependTo", ->

    it "prepends el to target", ->
      @view.prependTo "#konacha"
      $("#konacha").should.have @view.$el

    it "delegates events", ->
      @view.delegateEvents = @spy()
      @view.remove()
      @view.prependTo "#konacha"
      @view.delegateEvents.should.have.been.calledOnce

    it "can be chained", ->
      @view.appendTo("#konacha").should.equal @view

  describe "#insertAfter", ->

    beforeEach ->
      $("#konacha").append $("<div id='target'>")

    it "inserts el after target", ->
      @view.insertAfter "#target"
      $("#target").next().should.be @view.$el

    it "delegates events", ->
      @view.delegateEvents = @spy()
      @view.remove()
      @view.insertAfter "#target"
      @view.delegateEvents.should.have.been.calledOnce

    it "can be chained", ->
      @view.appendTo("#konacha").should.equal @view

  describe "#insertBefore", ->

    beforeEach ->
      $("#konacha").append $("<div id='target'>")

    it "inserts el before target", ->
      @view.insertBefore "#target"
      $("#target").prev().should.be @view.$el

    it "delegates events", ->
      @view.delegateEvents = @spy()
      @view.remove()
      @view.insertBefore "#target"
      @view.delegateEvents.should.have.been.calledOnce

    it "can be chained", ->
      @view.appendTo("#konacha").should.equal @view

  describe "#clear", ->

    it "can be chained", ->
      @view.clear().should.equal @view

    it "clears out el", ->
      @view.$el.append $("<p>foo</p>")
      @view.$el.appendTo "#konacha"
      @view.clear()
      @view.$el.should.be.empty

  describe "#remove", ->

    it "can be chained", ->
      @view.remove().should.equal @view

    it "calls remove on el", ->
      @view.$el.remove = @spy()
      @view.remove()
      @view.$el.remove.should.have.been.calledOnce

  describe "#dissolve", ->

    it "unbinds model", ->
      spy = @spy()
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
      @view.remove = @spy()
      @view.destroy()
      @view.remove.should.have.been.calledOnce

    it "dissolves view instance", ->
      @view.dissolve = @spy()
      @view.destroy()
      @view.dissolve.should.have.been.calledOnce

    it "can be chained", ->
      @view.appendTo("#konacha").should.equal @view
