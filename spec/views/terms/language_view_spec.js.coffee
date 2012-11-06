#= require spec_helper
#= require views/terms/language_view
#= require views/layout/section_view

describe "Coreon.Views.Terms.LanguageView", ->

  beforeEach ->
    @view = new Coreon.Views.Terms.LanguageView
      lang: "en"
      terms: []

  it "is a section view", ->
    @view.should.be.an.instanceof Coreon.Views.Layout.SectionView

  it "creates container", ->
    @view.options.lang = "hu"
    @view.initialize()
    @view.$el.should.have.class "language"
    @view.$el.should.have.class "hu"

  describe "#render", ->
  
    it "can be chained", ->
      @view.render().should.equal @view

    it "renders title", ->
      @view.options.lang = "es"
      @view.render()
      @view.$(".section-toggle").should.have.text "es"

    it "renders terms", ->
      @view.options.terms = [
        { value: "pistol" }
        { value: "revolver" }
      ]
      @view.render()
      @view.$(".term").length.should.equal 2
      @view.$(".term").eq(0).should.contain "pistol"
