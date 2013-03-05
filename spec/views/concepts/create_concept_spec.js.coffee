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

  describe "render_title()", ->

    it "is triggered by change:terms", ->
      @view.render_title = sinon.spy()
      @view.initialize()
      @view.model.trigger "change:terms"
      @view.render_title.should.have.been.calledOnce

    it "renders title", ->
      @view.render()
      @view.model.set "label", "foobar", silent: true
      @view.render_title()
      @view.$('.label').text().should.eql "foobar"

  describe "add_term()", ->

    beforeEach ->
      @view.render()

    it "is triggered by click on add term", ->
      @view.add_term = sinon.spy()
      @view.delegateEvents()
      @view.$(".add_term").click()
      @view.add_term.should.have.been.calledOnce

    it "calls add_term() on the model", ->
      @view.model.add_term = sinon.spy()
      @view.delegateEvents()
      @view.$(".add_term").click()
      @view.model.add_term.should.have.been.calledOnce

  describe "add_property()", ->

    beforeEach ->
      @view.render()

    it "is triggered by click on add property", ->
      @view.add_property = sinon.spy()
      @view.delegateEvents()
      @view.$(".add_property").click()
      @view.add_property.should.have.been.calledOnce

    it "calls add_property() on the model", ->
      @view.model.add_property = sinon.spy()
      @view.delegateEvents()
      @view.$(".add_property").click()
      @view.model.add_property.should.have.been.calledOnce


