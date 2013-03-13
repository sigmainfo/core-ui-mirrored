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

    it "is triggered by add:terms", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "add:terms"
      @view.render.should.have.been.calledOnce

    it "is triggered by remove:terms", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "remove:terms"
      @view.render.should.have.been.calledOnce

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

    it "is triggered by add:properties", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "add:properties"
      @view.render.should.have.been.calledOnce

    it "is triggered by remove:properties", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "remove:properties"
      @view.render.should.have.been.calledOnce

  describe "renderTitle()", ->

    it "is triggered by change:terms", ->
      @view.renderTitle = sinon.spy()
      @view.initialize()
      @view.model.trigger "change:terms"
      @view.renderTitle.should.have.been.calledOnce

    it "is triggered by change:properties", ->
      @view.renderTitle = sinon.spy()
      @view.initialize()
      @view.model.trigger "change:properties"
      @view.renderTitle.should.have.been.calledOnce

    it "renders title", ->
      @view.render()
      @view.model.set "label", "foobar", silent: true
      @view.renderTitle()
      @view.$('.label').text().should.eql "foobar"

  describe "addTerm()", ->

    beforeEach ->
      @view.render()

    it "is triggered by click on 'add term'", ->
      @view.addTerm = sinon.spy()
      @view.delegateEvents()
      @view.$(".add_term").click()
      @view.addTerm.should.have.been.calledOnce

    it "calls addTerm() on the model", ->
      @view.model.addTerm = sinon.spy()
      @view.delegateEvents()
      @view.$(".add_term").click()
      @view.model.addTerm.should.have.been.calledOnce

  describe "addProperty()", ->

    beforeEach ->
      @view.render()

    it "is triggered by click on 'add property'", ->
      @view.addProperty = sinon.spy()
      @view.delegateEvents()
      @view.$(".add_property").click()
      @view.addProperty.should.have.been.calledOnce

    it "calls addProperty() on the model", ->
      @view.model.addProperty = sinon.spy()
      @view.delegateEvents()
      @view.$(".add_property").click()
      @view.model.addProperty.should.have.been.calledOnce

  describe "create()", ->

    beforeEach ->
      @view.render()

    it "is triggered by click on 'create'", ->
      @view.create = sinon.spy()
      @view.delegateEvents()
      @view.$(".button.create").click()
      @view.create.should.have.been.calledOnce

    it "calls create() on the model", ->
      @view.model.create = sinon.spy()
      @view.delegateEvents()
      @view.$(".button.create").click()
      @view.model.create.should.have.been.calledOnce

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









