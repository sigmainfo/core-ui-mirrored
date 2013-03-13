#= require spec_helper
#= require views/terms/create_term_view

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
      @view.$el.should.have "a.remove_term"
      @view.$('a.remove_term').should.have.text "Remove Term"

    it "renders add property link", ->
      I18n.t.withArgs("create_concept.add_property").returns "Add Property"
      @view.render()
      @view.$el.should.have "a.add_term_property"
      @view.$('a.add_term_property').should.have.text "Add Property"

  describe "changes on inputs", ->

    beforeEach ->
      @view.render()

    it "triggers input_changed() on value change", ->
      @view.input_changed = sinon.spy()
      @view.delegateEvents()
      @view.$('.value input').trigger("change")
      @view.input_changed.should.have.been.called.once

    it "triggers input_changed() on language change", ->
      @view.input_changed = sinon.spy()
      @view.delegateEvents()
      @view.$('.language input').trigger("change")
      @view.input_changed.should.have.been.called.once

  describe "remove term", ->

    beforeEach ->
      @view.render()

    it "trigger remove_term() on 'Remove Term' button click", ->
      @view.remove_term = sinon.spy()
      @view.delegateEvents()
      @view.$('.remove_term').click()
      @view.remove_term.should.have.been.called.once

    it "removes itself from the collection", ->
      collection = new Backbone.Collection
      collection.push @view.model
      @view.$('.remove_term').click()
      collection.size().should.eql 0

  describe "validationFailure()", ->

    it "is triggered by validation error of the model", ->
      @view.validationFailure = sinon.spy()
      @view.initialize()
      @view.model.trigger "validationFailure", foo: "bar"
      @view.validationFailure.withArgs( foo: "bar" ).should.have.been.calledOnce

    it "sets class 'error' for term value on error", ->
      @view.render()
      @view.validationFailure value: ["error message"]
      @view.$('.value .input').should.have.class "error"

    it "sets class '.error' for term language on error", ->
      @view.render()
      @view.validationFailure lang: ["error message"]
      @view.$('.language .input').should.have.class "error"

    it "removes class '.error' from inputs on unrelated errors", ->
      @view.render()
      @view.$('.value .input').addClass 'error'
      @view.$('.language .input').addClass 'error'
      @view.validationFailure()
      @view.$('.value .input').should.not.have.class "error"
      @view.$('.language .input').should.not.have.class "error"

    it "displays error string for term value on 'can't be blank' error", ->
      I18n.t.withArgs("create_term.value_cant_be_blank").returns "Can't be blank"
      @view.render()
      @view.validationFailure value: ["can't be blank"]
      @view.$('.value .error_message').should.have.text "Can't be blank"
      @view.$('.language .error_message').should.not.have.text "Can't be blank"

    it "displays error string for term language on 'can't be blank' error", ->
      I18n.t.withArgs("create_term.language_cant_be_blank").returns "Can't be blank"
      @view.render()
      @view.validationFailure lang: ["can't be blank"]
      @view.$('.language .error_message').should.have.text "Can't be blank"

    it "removes error strings if error is not present anymore", ->
      @view.render()
      @view.validationFailure lang: ["can't be blank"], value: ["can't be blank"]
      @view.validationFailure()
      @view.$('.language .error_message').should.have.text ""
      @view.$('.value .error_message').should.have.text ""


