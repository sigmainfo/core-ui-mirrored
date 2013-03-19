#= require spec_helper
#= require views/concepts/create_concept_view
#= require models/concept

describe "Coreon.Views.Concepts.CreateConceptView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Concepts.CreateConceptView
      model: new Backbone.Model

  afterEach ->
    I18n.t.restore()

  it "is a backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  it "creates container", ->
    @view.$el.should.match ".create-concept"

  describe "render()", ->

    it "can be chained", ->
      @view.render().should.equal @view

    it "renders label", ->
      @view.model.set "label", "gun", silent: true
      @view.render()
      @view.$el.should.have "h2.label"
      @view.$('h2.label').should.have.text "gun"

    it "renders 'Add Property' link", ->
      I18n.t.withArgs("create_concept.add_property").returns "Add Property"
      @view.render()
      @view.$el.should.have "a.add_property"
      @view.$('a.add_property').should.have.text "Add Property"

    it "renders 'Add Term' link", ->
      I18n.t.withArgs("create_concept.add_term").returns "Add Term"
      @view.render()
      @view.$el.should.have "a.add_term"
      @view.$('a.add_term').should.have.text "Add Term"

    it "renders 'Create' button", ->
      I18n.t.withArgs("create_concept.create").returns "Create"
      @view.render()
      @view.$el.should.have ".create"
      @view.$('.create').should.have.text "Create"

    it "renders 'Cancel' button", ->
      I18n.t.withArgs("create_concept.cancel").returns "Cancel"
      @view.render()
      @view.$el.should.have ".cancel"
      @view.$('.cancel').should.have.text "Cancel"

    it "renders Terms headline", ->
      I18n.t.withArgs("create_concept.terms").returns "Terms"
      @view.render()
      @view.$('.terms h3').should.have.text "Terms"

    it "renders Term", ->
      term =  new Backbone.Model
      term.set "value", "gun", silent: true
      term.set "lang", "en", silent: true
      terms = new Backbone.Collection [term]
      @view.model.get = (attr) ->
        terms if attr is "terms"
      @view.render()
      @view.$el.should.have ".terms"
      @view.$('.terms').should.have ".create-term"
      @view.$('.create-term').should.have '.value'
      @view.$('.create-term').should.have '.language'

    it "renders Properties headline", ->
      I18n.t.withArgs("create_concept.properties").returns "Properties"
      @view.render()
      @view.$('.properties h3').should.have.text "Properties"

    it "renders Properties", ->
      @view.model.get = (attr) ->
        if attr is "properties"
          [ { lang : 'en', key: 'description', value: 'flowerz' } ]
      @view.render()
      @view.$el.should.have ".properties"
      @view.$('.properties').should.have ".create-property"
      @view.$('.create-property').should.have '.key'
      @view.$('.create-property').should.have '.value'
      @view.$('.create-property').should.have '.language'

    it "renders Broader Narrower headline", ->
      I18n.t.withArgs("concept.tree").returns "B & N"
      @view.render()
      @view.$('.broader_narrower h3').should.have.text "B & N"

    it "renders Broader Narrower section", ->
      @view.model.set "label", "concept_label"
      @view.render()
      @view.$('.broader_narrower').should.have ".super"
      @view.$('.broader_narrower').should.have ".sub"
      @view.$('.broader_narrower').should.have ".self"
      @view.$('.broader_narrower .self').should.have.text "concept_label"
      @view.$('.broader_narrower .super').should.have.text ""
      @view.$('.broader_narrower .sub').should.have.text ""

  describe "addTerm()", ->

    beforeEach ->
      @view.render()

    it "is triggered by click on 'add term'", ->
      @view.addTerm = sinon.spy()
      @view.delegateEvents()
      @view.$(".add_term").click()
      @view.addTerm.should.have.been.calledOnce

    it "appends new empty term view to term section", ->
      @view.model.addTerm = sinon.spy()
      @view.delegateEvents()
      @view.$(".add_term").click()
      @view.$('.terms').should.have ".create-term"
      @view.$('.create-term').should.have '.value'
      @view.$('.create-term').should.have '.language'
      @view.$('.create-term .value').should.have.value ''
      @view.$('.create-term .language').should.have.value ''

  describe "addProperty()", ->

    beforeEach ->
      @view.render()

    it "is triggered by click on 'add property'", ->
      @view.addProperty = sinon.spy()
      @view.delegateEvents()
      @view.$(".add_property").click()
      @view.addProperty.should.have.been.calledOnce

    it "appends new empty property to property section", ->
      @view.model.addProperty = sinon.spy()
      @view.delegateEvents()
      @view.$(".add_property").click()
      @view.$('.properties').should.have ".create-property"
      @view.$('.create-property').should.have '.key'
      @view.$('.create-property').should.have '.value'
      @view.$('.create-property').should.have '.language'
      @view.$('.create-property .key').should.have.value ''
      @view.$('.create-property .value').should.have.value ''
      @view.$('.create-property .language').should.have.value ''

  describe "create()", ->

    beforeEach ->
      @view.render()

    it "is triggered by click on 'create'", ->
      @view.create = sinon.spy()
      @view.delegateEvents()
      @view.$(".button.create").click()
      @view.create.should.have.been.calledOnce

    it "sets model to empty terms and properties by default", ->
      @view.model.set = sinon.spy()
      @view.model.create = sinon.spy()
      @view.delegateEvents()
      @view.$(".button.create").click()
      @view.model.set.withArgs( properties: [], terms: [] ).should.have.been.calledOnce

    it "sets model with the json of its form", ->
      @view.model.set = sinon.spy()
      @view.model.create = sinon.spy()
      @view.delegateEvents()
      @view._formToJs = sinon.stub().returns properties: ["foo"], terms: ["bar"]
      @view.create()
      @view.model.set.withArgs( properties: ["foo"], terms: ["bar"] ).should.have.been.calledOnce

    it "calls create() on the model", ->
      @view.model.create = sinon.spy()
      @view.delegateEvents()
      @view.$(".button.create").click()
      @view.model.create.should.have.been.calledOnce

    it "removes error messages", ->
      @view.model.set = sinon.spy()
      @view.model.create = sinon.spy()
      @view.$('.input').addClass 'error'
      @view.$('.error_message').html "errorz"
      @view.create()
      @view.$('.input').should.not.have.class 'error'
      @view.$('.error_message').should.not.have.text "errorz"

  describe "cancel()", ->

    beforeEach ->
      @view.render()

    it "is triggered by click on 'cancel'", ->
      @view.cancel = sinon.spy()
      @view.delegateEvents()
      @view.$(".button.cancel").click()
      @view.cancel.should.have.been.calledOnce

  describe "validationFailure()", ->

    it "is triggered by validation error of the model", ->
      @view.validationFailure = sinon.spy()
      @view.initialize()
      @view.model.trigger "validationFailure"
      @view.validationFailure.should.have.been.calledOnce

    it "displays general error message", ->
      I18n.t.withArgs("create_concept.validation_failure").returns "Validation Failure"
      @view.render()
      @view.validationFailure()
      @view.$('.errors p').should.have.text "Validation Failure"

    it "displays term error message", ->
      I18n.t.withArgs("create_concept.validation_failure_terms").returns "Term Validation Failure"
      @view.render()
      @view.validationFailure terms: [ "error message" ]
      @view.$('.errors li:first').should.have.text "Term Validation Failure"

    it "displays property error message", ->
      I18n.t.withArgs("create_concept.validation_failure_properties").returns "Property Validation Failure"
      @view.render()
      @view.validationFailure properties: [ "error message" ]
      @view.$('.errors li:first').should.have.text "Property Validation Failure"

    it "does not display error message on null errors", ->
      @view.render()
      @view.validationFailure
        nested_errors_on_properties: [ null ]
        nested_errors_on_terms: [ null ]
      @view.$('.errors ul').should.have.text ""

    it "creates error messages in term sections", ->
      I18n.t.withArgs("create_term.language_cant_be_blank").returns "Language can't be blank"
      I18n.t.withArgs("create_term.value_cant_be_blank").returns "Value can't be blank"
      @view.render()
      @view.$('.add_term').click()
      @view.$('.add_term').click()
      @view.validationFailure terms: ["error"], nested_errors_on_terms: [ null,
        value: ["can't be blank"],
        lang: ["can't be blank"]
      ]
      @view.$('.create-term:eq(1) .value .input').should.have.class "error"
      @view.$('.create-term:eq(1) .language .input').should.have.class "error"
      @view.$('.create-term:eq(1) .language .error_message').should.have.text "Language can't be blank"
      @view.$('.create-term:eq(1) .value .error_message').should.have.text "Value can't be blank"

    it "creates error messages in properties sections", ->
      I18n.t.withArgs("create_property.key_cant_be_blank").returns "Key can't be blank"
      I18n.t.withArgs("create_property.language_cant_be_blank").returns "Language can't be blank"
      I18n.t.withArgs("create_property.value_cant_be_blank").returns "Value can't be blank"
      @view.render()
      @view.$('.add_property').click()
      @view.$('.add_property').click()
      @view.validationFailure properties: ["error"], nested_errors_on_properties: [ null,
        value: ["can't be blank"],
        lang: ["can't be blank"]
        key: ["can't be blank"]
      ]
      @view.$('.create-property:eq(1) .key .input').should.have.class "error"
      @view.$('.create-property:eq(1) .value .input').should.have.class "error"
      @view.$('.create-property:eq(1) .language .input').should.have.class "error"
      @view.$('.create-property:eq(1) .key .error_message').should.have.text "Key can't be blank"
      @view.$('.create-property:eq(1) .value .error_message').should.have.text "Value can't be blank"
      @view.$('.create-property:eq(1) .language .error_message').should.have.text "Language can't be blank"



