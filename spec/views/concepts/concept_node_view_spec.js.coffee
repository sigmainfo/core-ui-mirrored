#= require spec_helper
#= require views/concepts/concept_node_view

describe "Coreon.Views.Concepts.ConceptNodeView", ->

  beforeEach ->
    svg = d3.select $("<svg>").appendTo("#konacha").get(0)
    model = new Backbone.Model sub_concept_ids: [], super_concept_ids: []
    model.label = -> "#123"
    model.hit = -> false
    @view = new Coreon.Views.Concepts.ConceptNodeView
      el: svg.append("g").node()
      model: model
      node:
        treeUp: []
        treeDown: []
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

    it "creates children toggle", ->
      @view.model.set "sub_concept_ids", ["123"], silent: true
      sinon.stub SVGRectElement::, "getBBox", ->
        x: 0, y: 0, width: 50, height: 20 
      try
        @view.render()
        @view.$el.should.have ".toggle-children"
        @view.$(".toggle-children").attr("transform").should.equal "translate(50, 0)"
      finally
        SVGRectElement::getBBox.restore()
    
    it "does not create children toggle for leaves", ->
      @view.model.set "sub_concept_ids", [], silent: true
      @view.render()
      @view.$el.should.not.have ".toggle-children"

    it "classifies expanded toggles", ->
      @view.model.set {sub_concept_ids: ["123"], super_concept_ids: ["456"]}, silent: true
      @view.options.node = treeUp: [{}], treeDown: [{}]
      @view.render()
      d3.select( @view.$(".toggle-children").get(0) ).classed("expanded").should.be.true
      d3.select( @view.$(".toggle-parents").get(0) ).classed("expanded").should.be.true

    it "creates parents toggle", ->
      @view.model.set "super_concept_ids", ["123"], silent: true
      sinon.stub SVGRectElement::, "getBBox", ->
        x: 0, y: 0, width: 50, height: 20 
      try
        @view.render()
        @view.$el.should.have ".toggle-parents"
        @view.$(".toggle-parents").attr("transform").should.equal "translate(-20, 0)"
      finally
        SVGRectElement::getBBox.restore()
    
    it "does not create parents toggle for roots", ->
      @view.model.set "super_concept_ids", [], silent: true
      @view.render()
      @view.$el.should.not.have ".toggle-parents"

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
