#= require spec_helper
#= require views/concepts/concept_node_view

describe "Coreon.Views.Concepts.ConceptNodeView", ->

  beforeEach ->
    svg = d3.select $("<svg>").appendTo("#konacha").get(0)
    model = new Backbone.Model
    model.label = -> "#123"
    model.hit = -> false
    @view = new Coreon.Views.Concepts.ConceptNodeView
      el: svg.append("g").node()
      model: model
    @el = d3.select @view.el

  afterEach ->
    @view.destroy()

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  describe "initialize()", ->
  
    it "adds class to el", ->
      @el.attr("class").should.equal "concept-node"

  describe "render()", ->

    it "is triggered by model change", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.set "properties", [ key: "label", value: "Colt" ]
      @view.render.should.have.been.calledOnce
  
    it "renders label text", ->
      @view.model.label = -> "Revolver"
      @view.render()
      @el.select("text").text().should.equal "Revolver"

    it "shortens lengthy labels", ->
      @view.model.label = -> "Horticultural mulches made from cocoa shell waste"
      @view.render()
      @el.select("text").text().should.equal "Horticultur…"

    it "renders link to concept", ->
      @view.model.id = "nobody"
      @view.render()
      @el.select("a").attr("xlink:href").should.equal "/concepts/nobody"

    it "adjusts bg width to label length", ->
      sinon.stub SVGTextElement::, "getBBox", ->
        x: 10
        y: 5
        width:100
        height: 20
      try
        @view.render()
        @el.select(".background").attr("width").should.equal "113"
      finally
        SVGTextElement::getBBox.restore()

    it "classifies hit", ->
      @view.model.hit = -> true
      @view.render()
      @el.classed("hit").should.be.true

    it "removes hit class when no longer valid", ->
      @view.model.hit = -> true
      @view.render()
      @view.model.hit = -> false
      @view.render()
      @el.classed("hit").should.be.false

  describe "toggleHit", ->

    it "classifies hit on hit add", ->
      @view.model.hit = -> true
      @view.model.trigger "hit:add"
      @el.classed("hit").should.be.true

    it "classifies hit on hit remove", ->
      @view.model.hit = -> true
      @view.render()
      @view.model.hit = -> false
      @view.model.trigger "hit:remove"
      @el.classed("hit").should.not.be.true

  describe "dissolve()", ->
  
    it "dissolves model", ->
      @view.model.off = sinon.spy()
      @view.dissolve()
      @view.model.off.should.have.been.calledOnce
      @view.model.off.should.have.been.calledWith null, null, @view

  describe "remove()", ->

    it "removes svg element", ->
      @view.svg.remove = sinon.spy()
      @view.remove()
      @view.svg.remove.should.have.been.calledOnce
