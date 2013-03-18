#= require spec_helper
#= require views/properties/create_property_view

describe "Coreon.Views.Properties.CreatePropertyView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Properties.CreatePropertyView index: 42

  afterEach ->
    I18n.t.restore()

  it "is a backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  it "creates container", ->
    @view.$el.should.match ".create-property"

  describe "render()", ->

    it "can be chained", ->
      @view.render().should.equal @view

    it "renders empty property key by default", ->
      @view.render()
      @view.$el.should.have ".key"
      @view.$el.should.have ".key input"
      @view.$('.key input').val().should.equal ""
      @view.$('.key input').attr('name').should.equal "concept[properties][42][key]"
      @view.$('.key input').attr('id').should.equal "concept_properties_42_key"

    it "renders property key", ->
      @view.key = "description"
      @view.render()
      @view.$el.should.have ".key"
      @view.$el.should.have ".key input"
      @view.$('.key input').val().should.equal "description"
      @view.$('.key input').attr('name').should.equal "concept[properties][42][key]"
      @view.$('.key input').attr('id').should.equal "concept_properties_42_key"

    it "renders label for property key", ->
      I18n.t.withArgs("create_property.key").returns "Property Key"
      @view.render()
      @view.$el.should.have ".key"
      @view.$el.should.have ".key label"
      @view.$('.key label').should.have.text "Property Key"
      @view.$('.key label').attr('for').should.equal "concept_properties_42_key"

    it "renders empty property value by default", ->
      @view.render()
      @view.$el.should.have ".value"
      @view.$el.should.have ".value input"
      @view.$('.value input').val().should.equal ""
      @view.$('.value input').attr('name').should.equal "concept[properties][42][value]"
      @view.$('.value input').attr('id').should.equal "concept_properties_42_value"

    it "renders property value", ->
      @view.value = "flower"
      @view.render()
      @view.$el.should.have ".value"
      @view.$el.should.have ".value input"
      @view.$('.value input').val().should.equal "flower"
      @view.$('.value input').attr('name').should.equal "concept[properties][42][value]"
      @view.$('.value input').attr('id').should.equal "concept_properties_42_value"

    it "renders label for property key", ->
      I18n.t.withArgs("create_property.value").returns "Property Value"
      @view.render()
      @view.$el.should.have ".value"
      @view.$el.should.have ".value label"
      @view.$('.value label').should.have.text "Property Value"
      @view.$('.value label').attr('for').should.equal "concept_properties_42_value"

    it "renders empty property language by default", ->
      @view.render()
      @view.$el.should.have ".language"
      @view.$el.should.have ".language input"
      @view.$('.language input').val().should.equal ""
      @view.$('.language input').attr('name').should.equal "concept[properties][42][lang]"
      @view.$('.language input').attr('id').should.equal "concept_properties_42_lang"

    it "renders property language", ->
      @view.lang = "en"
      @view.render()
      @view.$el.should.have ".language"
      @view.$el.should.have ".language input"
      @view.$('.language input').val().should.equal "en"
      @view.$('.language input').attr('name').should.equal "concept[properties][42][lang]"
      @view.$('.language input').attr('id').should.equal "concept_properties_42_lang"

    it "renders label for property language", ->
      I18n.t.withArgs("create_property.language").returns "Property Language"
      @view.render()
      @view.$el.should.have ".language"
      @view.$el.should.have ".language label"
      @view.$('.language label').should.have.text "Property Language"
      @view.$('.language label').attr('for').should.equal "concept_properties_42_lang"

    it "renders remove property link", ->
      I18n.t.withArgs("create_property.remove").returns "Remove Property"
      @view.render()
      @view.$el.should.have "a.remove_property"
      @view.$('a.remove_property').should.have.text "Remove Property"

  describe "remove property", ->

    beforeEach ->
      @view.render()

    it "triggers remove_property() on 'Remove Property' button click", ->
      @view.remove_property = sinon.spy()
      @view.delegateEvents()
      @view.$('.remove_property').click()
      @view.remove_property.should.have.been.called.once

    it "removes itself", ->
      @view.remove = sinon.spy()
      @view.$('.remove_property').click()
      @view.remove.should.have.been.called.Once

  describe "validationFailure()", ->

    it "sets class 'error' for property key on error", ->
      @view.render()
      @view.validationFailure 42, key: ["error message"]
      @view.$('.key .input').should.have.class "error"

    it "sets class 'error' for property value on error", ->
      @view.render()
      @view.validationFailure 42, value: ["error message"]
      @view.$('.value .input').should.have.class "error"

    it "sets class 'error' for property language on error", ->
      @view.render()
      @view.validationFailure 42, lang: ["error message"]
      @view.$('.language .input').should.have.class "error"

    it "removes class '.error' from inputs on unrelated errors", ->
      @view.render()
      @view.$('.key .input').addClass 'error'
      @view.$('.value .input').addClass 'error'
      @view.$('.language .input').addClass 'error'
      @view.validationFailure()
      @view.$('.key .input').should.not.have.class "error"
      @view.$('.value .input').should.not.have.class "error"
      @view.$('.language .input').should.not.have.class "error"

    it "displays error string for property key on 'can't be blank' error", ->
      I18n.t.withArgs("create_property.key_cant_be_blank").returns "Can't be blank"
      @view.render()
      @view.validationFailure 42, key: ["can't be blank"]
      @view.$('.key .error_message').should.have.text "Can't be blank"

    it "displays error string for property value on 'can't be blank' error", ->
      I18n.t.withArgs("create_property.value_cant_be_blank").returns "Can't be blank"
      @view.render()
      @view.validationFailure 42, value: ["can't be blank"]
      @view.$('.value .error_message').should.have.text "Can't be blank"

    it "removes error strings if error is not present anymore", ->
      @view.render()
      @view.validationFailure 42, key: ["can't be blank"], value: ["can't be blank"]
      @view.validationFailure()
      @view.$('.key .error_message').should.have.text ""
      @view.$('.value .error_message').should.have.text ""

