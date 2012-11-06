#= require spec_helper
#= require views/terms/term_view

describe "Coreon.Views.Terms.TermView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Terms.TermView
      term:
        value: "pistol"

  afterEach ->
    I18n.t.restore()

  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView

  it "creates container", ->
    @view.$el.should.have.class "term"

  describe "#render", ->
  
    it "can be chained", ->
      @view.render().should.equal @view

    it "renders value", ->
      @view.options.term.value = "gat"
      @view.render()
      @view.$el.should.have "h4.value"
      @view.$("h4.value").should.have.text "gat"

    it "renders properties", ->
      I18n.t.withArgs("properties.title").returns "Properties"
      @view.options.term.properties = [
        { key: "foo", value: "bar" }
      ]
      @view.render()
      @view.$el.should.have ".properties"
      @view.$el.should.have ".properties .section-toggle"
      @view.$(".section-toggle").should.have.text "Properties"
      @view.$(".section-toggle").should.have.class "collapsed"
      @view.$(".section table th").eq(0).should.have.text "foo"

    it "renders properties only when not empty", ->
      @view.options.term.properties = []
      @view.render()
      @view.$el.should.not.have ".properties"

    it "renders system info", ->
      I18n.t.withArgs("term.info").returns "Term Info"
      $("#konacha").append @view.$el
      @view.options.term._id = "abcd1234"
      @view.options.term.source = "http://iate.europa.eu"
      @view.render()
      @view.$el.should.have ".system-info-toggle"
      @view.$(".system-info-toggle").should.have.text "Term Info"
      @view.$el.should.have ".system-info"
      @view.$(".system-info").should.be.hidden
      @view.$(".system-info th").eq(0).should.have.text "id"
      @view.$(".system-info td").eq(0).should.have.text "abcd1234"
      @view.$(".system-info th").eq(1).should.have.text "source"
      @view.$(".system-info td").eq(1).should.have.text "http://iate.europa.eu"
    
  describe "#toggleInfo", ->

    beforeEach ->
      @event = new jQuery.Event "click"
      @view.render()
  
    it "is triggered by click on system info toggle", ->
      @view.toggleInfo = sinon.spy()
      @view.delegateEvents()
      @view.$(".system-info-toggle").click()
      @view.toggleInfo.should.have.been.calledOnce

    it "toggles system info", ->
      $("#konacha").append(@view.$el)
      @view.$(".system-info").should.be.hidden
      @view.toggleInfo @event
      @view.$(".system-info").should.be.visible
      @view.toggleInfo @event
      @view.$(".system-info").should.be.hidden

    it "does not propagate", ->
      @event.stopPropagation = sinon.spy()
      @view.toggleInfo @event
      @event.stopPropagation.should.have.been.calledOnce
