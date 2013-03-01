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

    it "renders term language", ->
      @view.model.set "lang", "en", silent: true
      @view.render()
      @view.$el.should.have ".language"
      @view.$('.language').should.have "input"
      @view.$('.language input').val().should.equal "en"
      @view.$('.language input').attr('name').should.equal "concept[terms][#{@view.model.cid}][lang]"
      @view.$('.language input').attr('id').should.equal "concept_terms_#{@view.model.cid}_lang"

    it "renders label for language", ->
      I18n.t.withArgs("create_term.language").returns "Language"
      @view.render()
      @view.$el.should.have ".language"
      @view.$('.language').should.have "label"
      @view.$('.language label').should.have.text "Language"
      @view.$('.language label').attr('for').should.equal "concept_terms_#{@view.model.cid}_lang"

    it "renders remove term link", ->
      I18n.t.withArgs("create_term.remove_term").returns "Remove Term"
      @view.render()
      @view.$el.should.have "h3.remove_term"
      @view.$('h3.remove_term').should.have.text "Remove Term"

    it "renders add property link", ->
      I18n.t.withArgs("create_concept.add_property").returns "Add Property"
      @view.render()
      @view.$el.should.have "h3.add_property"
      @view.$('h3.add_property').should.have.text "Add Property"

  describe "changes on inputs", ->

    it "trigger input_changed()", ->
      @view.render()
      @view.input_changed = sinon.spy()
      @view.delegateEvents()
      @view.$('.value input').trigger("change")
      @view.input_changed.should.have.been.called.once

    it "trigger change ", ->
      @view.render()
      @view.input_changed = sinon.spy()
      @view.delegateEvents()
      @view.$('.value input').trigger("change")
      @view.input_changed.should.have.been.called.once


        # @view.fill_in "Term Value", "foobar"
        #fill_in

        #@view.$el





