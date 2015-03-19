#= require spec_helper
#= require views/concepts/shared/associative_relations/show_view

describe "Coreon.Views.Concepts.Shared.AssociativeRelations.ShowView", ->

  view = null
  model = null
  el = null

  createAndRender = ->
    view = new Coreon.Views.Concepts.Shared.AssociativeRelations.ShowView model: model
    el = view.render().$el

  beforeEach ->
    model =
      relations: []
    sinon.stub Coreon.Views.Concepts, 'ConceptLabelView', -> new Backbone.View
    sinon.stub Coreon.Models.Concept, 'find', -> new Backbone.Model
    view = new Coreon.Views.Concepts.Shared.AssociativeRelations.ShowView model: model

  afterEach ->
    Coreon.Views.Concepts.ConceptLabelView.restore()
    Coreon.Models.Concept.find.restore()

  it "is a Backbone view", ->
    expect(view).to.be.an.instanceof Backbone.View

  it "has a section container", ->
    expect(view.$el).to.be "tr"

  it "has a class", ->
    expect(view.$el).to.have.class "relation-type"

  it "has a template", ->
    expect(view).to.have.property 'template', Coreon.Templates["concepts/shared/associative_relations/show"]

  describe "#render()", ->

    relations = null

    beforeEach ->
      relations = []
      model = {
        relationType: {
          key: 'see also',
          icon: 'see-also'
        }
        relations: relations
      }

    it "renders a title for this type of relation", ->
      createAndRender()
      title = el.find('th')
      expect(title).to.contain 'see also'

    it "renders a list of concept labels", ->
      relations.push {id: '1'}
      relations.push {id: '2'}
      createAndRender()
      expect(Coreon.Views.Concepts.ConceptLabelView).to.have.been.calledTwice