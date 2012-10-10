#= require spec_helper
#= require views/layout/section_view

describe "Coreon.Views.Layout.SectionView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Layout.SectionView
    @view.sectionTitle = "outer"

  afterEach ->
    I18n.t.restore()

  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView
    
  describe "#render", ->

    it "calls super", ->
      @view.subviews = [ render: sinon.spy() ]
      @view.render()
      @view.subviews[0].render.should.have.been.calledOnce

    it "can be chained", ->
      @view.render().should.equal @view
  
    it "renders title", ->
      @view.sectionTitle = "Broader & Narrower"
      @view.render()
      @view.$el.should.have ".section-toggle"
      @view.$(".section-toggle").should.have.text "Broader & Narrower"

    it "renders title from function", ->
      @view.sectionTitle = -> ["Broader", "&", "Narrower"].join " "
      @view.render()
      @view.$(".section-toggle").should.have.text "Broader & Narrower"

    it "renders section container", ->
      @view.render()
      @view.$el.should.have ".section"
      
  describe "#toggle", ->

    beforeEach ->
      @view.render()

    it "is triggered by click on headline", ->
      @view.toggle = sinon.spy()
      @view.delegateEvents()
      @view.$(".section-toggle").click()
      @view.toggle.should.have.been.calledOnce

    it "toggles section", ->
      $("#konacha").append @view.$el
      @view.$(".section").should.be.visible
      @view.$(".section-toggle").click()
      @view.$(".section").should.not.be.visible
      @view.$(".section-toggle").click()
      @view.$(".section").should.be.visible

    it "toggles state of section toggle", ->
      @view.$(".section-toggle").should.not.have.class "collapsed"
      @view.$(".section-toggle").click()
      @view.$(".section-toggle").should.have.class "collapsed"
      @view.$(".section-toggle").click()
      @view.$(".section-toggle").should.not.have.class "collapsed"

    it "puts toggle into default state", ->
      $("#konacha").append @view.$el
      @view.options.collapsed = true
      @view.render()
      @view.$(".section-toggle").should.have.class "collapsed"
      @view.$(".section").should.be.hidden

    context "nested", ->
    
      beforeEach ->
        $("#konacha").append @view.$el
        subview = new Coreon.Views.Layout.SectionView
        subview.sectionTitle = "inner"
        @view.append ".section", subview.render()

      it "is not triggered by nested section", ->
        @view.$(".section .section-toggle").click()
        @view.$(".section-toggle").first().should.not.have.class "collapsed"
        @view.$(".section").should.be.visible
        @view.$(".section .section-toggle").should.have.class "collapsed"
        @view.$(".section .section").should.be.hidden

      it "does not toggle nested section", ->
        @view.$(".section-toggle").first().click()
        @view.$(".section-toggle").first().should.have.class "collapsed"
        @view.$(".section").should.be.hidden
        @view.$(".section .section-toggle").should.not.have.class "collapsed"

    context "multiple toggles", ->

      beforeEach ->
        $("#konacha").append @view.$el
        @
        
