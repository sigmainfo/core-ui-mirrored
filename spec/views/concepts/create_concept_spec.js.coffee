#= require spec_helper
#= require views/concepts/create_concept_view
#= require models/concept

describe "Coreon.Views.Concepts.CreateConceptView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Concepts.CreateConceptView
      model: new Coreon.Models.Concept

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
      I18n.t.withArgs("create_properties.add").returns "Create Property"
      @view.render()
      @view.$el.should.have "h3.add_property"
      @view.$('h3.add_property').should.have.text "Create Property"

    it "renders 'Add Term' link", ->
      I18n.t.withArgs("create_terms.add").returns "Create Term"
      @view.render()
      @view.$el.should.have "h3.add_term"
      @view.$('h3.add_term').should.have.text "Create Term"

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
      
