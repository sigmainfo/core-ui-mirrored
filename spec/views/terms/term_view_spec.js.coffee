#= require spec_helper
#= require views/terms/term_view

describe "Coreon.Views.Terms.TermView", ->

  beforeEach ->
    @view = new Coreon.Views.Terms.TermView
      term:
        value: "pistol"

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
      @view.options.term.properties = [
        { key: "foo", value: "bar" }
      ]
      @view.render()
      @view.$el.should.have ".properties"
      @view.$el.should.have ".properties .section-toggle"
      @view.$(".section-toggle").should.have.text "Properties"
      @view.$(".section-toggle").should.have.class "collapsed"
      @view.$(".section table th").should.have.text "foo"

    it "renders properties only when not empty", ->
      @view.options.term.properties = []
      @view.render()
      @view.$el.should.not.have ".properties"
