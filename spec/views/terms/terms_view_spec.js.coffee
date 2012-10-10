#= require spec_helper
#= require views/terms/terms_view

describe "Coreon.Views.Terms.TermsView", ->

  beforeEach ->
    @view = new Coreon.Views.Terms.TermsView
      model: new Backbone.Model

  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView

  it "creates container", ->
    @view.$el.should.have.class "terms"

  describe "#render", ->
    
    it "can be chained", ->
      @view.render().should.equal @view

    it "renders section for each language", ->
      @view.model.set "terms", [
        { value: "gun"     , lang: "en" }
        { value: "pistol"  , lang: "en" }
        { value: "Pistole" , lang: "de" }
      ], silent: true
      @view.render()
      @view.$(".section-toggle").length.should.equal 2
      @view.$(".section-toggle").eq(0).should.have.text "en"
      @view.$(".section-toggle").eq(1).should.have.text "de"
      @view.$(".section").eq(0).should.contain "gun"
    
