#= require spec_helper
#= require views/layout/section_view

describe "Coreon.Views.Layout.SectionView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Layout.SectionView

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

    it "is can be chained", ->
      @view.toggle().should.equal @view
  
    it "is triggered by click on headline", ->
      @view.toggle = sinon.spy()
      @view.delegateEvents()
      @view.$(".section-toggle").click()
      @view.toggle.should.have.been.calledOnce

    it "toggles section", ->
      $("#konacha").append @view.$el
      @view.$(".section").should.be.visible
      @view.toggle()
      @view.$(".section").should.not.be.visible
      @view.toggle()
      @view.$(".section").should.be.visible

    it "toggles state of section tooggle", ->
      @view.$(".section-toggle").should.not.have.class "collapsed"
      @view.toggle()
      @view.$(".section-toggle").should.have.class "collapsed"
      @view.toggle()
      @view.$(".section-toggle").should.not.have.class "collapsed"
      
