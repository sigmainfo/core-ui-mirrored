#= require spec_helper
#= require views/terms/create_term_view
# require models/term

describe "Coreon.Views.Terms.CreateTermsView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Terms.CreateTermView
      model: new Backbone.Model

  afterEach ->
    I18n.t.restore()

  it "is a backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  it "creates container", ->
    @view.$el.should.match ".create-term"

  describe "render()", ->

    it "can be chained", ->
      @view.render().should.equal @view


    it "noch die label <-> name machen und id", ->
      @view.render()

    it "renders term value", ->
      @view.model.set "value", "gun", silent: true
      @view.render()
      @view.$el.should.have ".value"
      @view.$('.value').should.have "input"
      @view.$('.value input').val().should.equal "gun"
      @view.$('.value input').attr('name').should.equal "concept[terms][#{@view.model.cid}][value]"
      @view.$('.value input').attr('id').should.equal "concept_terms_#{@view.model.cid}_value"

    it "renders label for term value", ->
      I18n.t.withArgs("create_term.value").returns "Term Value"
      @view.render()
      @view.$el.should.have ".value"
      @view.$('.value').should.have "label"
      @view.$('.value label').should.have.text "Term Value"
      @view.$('.value label').attr('for').should.equal "concept_terms_#{@view.model.cid}_value"

    it "renders label for language", ->
      I18n.t.withArgs("create_term.language").returns "Language"
      @view.render()
      @view.$el.should.have ".language"
      @view.$('.language').should.have "label"
      @view.$('.language label').should.have.text "Language"

    it "renders term language", ->
      @view.model.set "lang", "en", silent: true
      @view.render()
      @view.$el.should.have ".language"
      @view.$('.language').should.have "input"
      @view.$('.language input').val().should.equal "en"

