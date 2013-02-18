#= require spec_helper
#= require views/concepts/concept_node_view

describe "Coreon.Views.Concepts.ConceptNodeView", ->

  beforeEach ->
    svg = d3.select $("<svg>").appendTo("#konacha").get(0)
    @view = new Coreon.Views.Concepts.ConceptNodeView
      el: svg.append("g").node()
      model: new Backbone.Model(label: "concept#123")
    @el = d3.select @view.el

  afterEach ->
    @view.remove()

  it "is a SVGView", ->
    @view.should.be.an.instanceof Coreon.Views.SVGView

  describe "render()", ->

    it "is triggered by model changes", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "change"
      @view.render.should.have.been.calledOnce

    it "is cleared before rerendering", ->
      @view.render()
      @view.render()
      @el.selectAll("a")[0].should.have.length 1

    it "can be chained", ->
      @view.render().should.equal @view

    it "renders link to concept", ->
      @view.model.id = "nobody"
      @view.render()
      @el.select("a").attr("xlink:href").should.equal "/concepts/nobody"

    it "classifies hit", ->
      @view.model.set "hit", { score: 1.5 },  silent: true
      @view.render()
      @el.classed("hit").should.be.true

    it "does not classify as hit by default", ->
      @view.model.set "hit", null,  silent: true
      @view.render()
      @el.classed("hit").should.be.false

    context "label", ->

      it "renders label text", ->
        @view.model.set "label", "Revolver"
        @view.render()
        @el.select("text").text().should.equal "Revolver"

      it "shortens lengthy labels", ->
        @view.model.set "label", "Horticultural mulches made from cocoa shell waste", silent: true
        @view.render()
        @el.select("text").text().should.equal "Horticult…"

      it "renders circle", ->
        @view.render()
        @el.select("circle").attr("class").should.equal "bullet"

      it "renders background", ->
        @view.render()
        @el.select("rect").attr("class").should.equal "background"
        
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

    context "toggle for subconcepts", ->

      beforeEach ->
        @view.model.set "sub_concept_ids", ["123"], silent: true
      
      it "renders toggle", ->
        @view.render()
        @view.$el.should.have ".toggle-children"

      it "positions toggle on right side of box", ->
        @view.box = -> x: 0, y: 0, width: 50, height: 20
        @view.render()
        @view.$(".toggle-children").attr("transform").should.equal "translate(50, 0)"
      
      it "does not create children toggle for leaves", ->
        @view.model.set "sub_concept_ids", [], silent: true
        @view.render()
        @view.$el.should.not.have ".toggle-children"

      it "classifies expanded toggle", ->
        @view.model.set "expandedOut", true, silent: true
        @view.render()
        @view.$(".toggle-children").attr("class").should.match /\bexpanded\b/

      it "rotates icon for expanded toggle", ->
        @view.model.set "expandedOut", true, silent: true
        @view.render()
        @view.$(".toggle-children .icon").attr("transform").should.equal "rotate(90, 0, 0)" 
        
      it "does not classify collapsed toggle", ->
        @view.model.set "expandedOut", false, silent: true
        @view.render()
        @view.$(".toggle-children").attr("class").should.not.match /\bexpanded\b/

      it "does not rotate icon for collapsed toggle", ->
        @view.model.set "expandedOut", false, silent: true
        @view.render()
        should.not.exist @view.$(".toggle-children .icon").attr("transform") 

  describe "box()", ->

    it "defaults dimensions to zero", ->
      @view.box().should.eql { x: 0, y: 0, height: 0, width: 0 }
    
    it "returns boundaries from background", ->
      @view.render()
      @view.bg.node = -> getBBox: -> { x: 5, y: 15, height: 30, width: 120 }
      @view.box().should.eql { x: 5, y: 15, height: 30, width: 120 }

  describe "toggleChildren()", ->

    beforeEach ->
      @view.model.set {
        super_concept_ids: ["456"],
        sub_concept_ids: ["333"]
      }, silent: true
      @event = document.createEvent "MouseEvents"
      @event.initMouseEvent "click", true, true, window,
        0, 0, 0, 0, 0, false, false, false, false, 0, null
      
    it "is triggered by click on toggle", ->
      @view.toggleChildren = sinon.spy()
      @view.render()
      @view.$(".toggle-children").get(0).dispatchEvent @event
      @view.toggleChildren.should.have.been.calledOnce

    it "toggles model state", ->
      @view.model.set "expandedOut", false, silent: true
      @view.toggleChildren()
      @view.model.get("expandedOut").should.be.true
      @view.toggleChildren()
      @view.model.get("expandedOut").should.be.false
    



  #   it "classifies expanded toggles", ->
  #     @view.model.set {sub_concept_ids: ["123"], super_concept_ids: ["456"]}, silent: true
  #     @view.options.node = treeUp: [{}], treeDown: [{}]
  #     @view.render()
  #     d3.select( @view.$(".toggle-children").get(0) ).classed("expanded").should.be.true
  #     d3.select( @view.$(".toggle-parents").get(0) ).classed("expanded").should.be.true

  #   it "creates parents toggle", ->
  #     @view.model.set "super_concept_ids", ["123"], silent: true
  #     sinon.stub SVGRectElement::, "getBBox", ->
  #       x: 0, y: 0, width: 50, height: 20 
  #     try
  #       @view.render()
  #       @view.$el.should.have ".toggle-parents"
  #       @view.$(".toggle-parents").attr("transform").should.equal "translate(-20, 0)"
  #     finally
  #       SVGRectElement::getBBox.restore()
  #   
  #   it "does not create parents toggle for roots", ->
  #     @view.model.set "super_concept_ids", [], silent: true
  #     @view.render()
  #     @view.$el.should.not.have ".toggle-parents"


  # describe "toggle", ->

  #     beforeEach ->
  #       @view.model.set {super_concept_ids: ["456"], sub_concept_ids: ["333"]}, silent: true
  #       @event = document.createEvent "MouseEvents"
  #       @event.initMouseEvent "click", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null
  # 
  #     it "is triggered by clicking on parents toggle", ->
  #       spy = sinon.spy()
  #       d3.select(@view.el).data [ foo: "bar" ]
  #       @view.render()
  #       @view.on "toggle:parents", spy
  #       @view.$(".toggle-parents").get(0).dispatchEvent @event
  #       spy.should.have.been.calledOnce
  #       spy.should.have.been.calledWith foo: "bar"
  #     
  #     it "is triggered by clicking on children toggle", ->
  #       spy = sinon.spy()
  #       d3.select(@view.el).data [ foo: "bar" ]
  #       @view.render()
  #       @view.on "toggle:children", spy
  #       @view.$(".toggle-children").get(0).dispatchEvent @event
  #       spy.should.have.been.calledOnce
  #       spy.should.have.been.calledWith foo: "bar"

  # describe "dissolve()", ->
  # 
  #   it "dissolves model", ->
  #     @view.model.off = sinon.spy()
  #     @view.dissolve()
  #     @view.model.off.should.have.been.calledOnce
  #     @view.model.off.should.have.been.calledWith null, null, @view

  # describe "remove()", ->

  #   it "removes svg element", ->
  #     @view.svg.remove = sinon.spy()
  #     @view.remove()
  #     @view.svg.remove.should.have.been.calledOnce
