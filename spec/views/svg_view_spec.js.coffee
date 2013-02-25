#= require spec_helper
#= require views/svg_view

describe "Coreon.Views.SVGView", ->


  beforeEach ->
    @svg = d3.select $("<svg>").appendTo("#konacha").get(0)
    @view = new Coreon.Views.SVGView
      el: @svg.append("svg:g").node()

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View
  
  describe "setElement()", ->

    it "can be chained", ->
      @view.setElement().should.equal @view

    it "calls super", ->
      sinon.spy Backbone.View::, "setElement"
      g = @svg.append "svg:g"
      try
        @view.setElement g, true
        Backbone.View::setElement.callCount.should.equal 1
        Backbone.View::setElement.firstCall.args.should.have.length 2
        Backbone.View::setElement.firstCall.args[0].should.equal g
        Backbone.View::setElement.firstCall.args[1].should.be.true
      finally
        Backbone.View::setElement.restore()

    it "creates a d3 selection for el", ->
      g = @svg.append "svg:g"
      @view.setElement g
      @view.svg.node().should.equal g

  describe "clear()", ->

    it "can be chained", ->
      @view.clear().should.equal @view
    
    it "empties el", ->
      @view.svg.append "svg:circle"
      @view.svg.append "svg:rect"
      @view.clear()
      @view.$el.should.be.empty
    
  describe "remove()", ->
  
    it "can be chained", ->
      @view.remove().should.equal @view

    it "calls remove on d3 selection", ->
      @view.svg.remove = sinon.spy()
      @view.remove()
      @view.svg.remove.should.have.been.calledOnce

    it "dissolves listeners", ->
      @view.stopListening = sinon.spy()
      @view.remove()
      @view.stopListening.should.have.been.calledOnce
      @view.stopListening.should.have.been.calledWithExactly()
    
