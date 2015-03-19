#= require spec_helper
#= require views/concepts/shared/associative_relations/edit_view

describe "Coreon.Views.Concepts.Shared.AssociativeRelations.EditView", ->

  view = null
  model = null
  el = null
  relations = null

  create = ->
    view = new Coreon.Views.Concepts.Shared.AssociativeRelations.EditView model: model

  createAndRender = ->
    view = new Coreon.Views.Concepts.Shared.AssociativeRelations.EditView model: model
    el = view.render().$el

  beforeEach ->
    model =
      relations: []
    sinon.stub Coreon.Views.Concepts, 'ConceptLabelView', -> new Backbone.View
    sinon.stub Coreon.Models.Concept, 'find', -> new Backbone.Model
    view = new Coreon.Views.Concepts.Shared.AssociativeRelations.EditView model: model

  afterEach ->
    Coreon.Views.Concepts.ConceptLabelView.restore()
    Coreon.Models.Concept.find.restore()

  it "is a Backbone view", ->
    create()
    expect(view).to.be.an.instanceof Backbone.View

  it "has a section container", ->
    create()
    expect(view.$el).to.be "tr"

  it "has a class", ->
    create()
    expect(view.$el).to.have.class "relation-type"
    expect(view.$el).to.have.class "edit-mode"

  it "has a template", ->
    create()
    expect(view).to.have.property 'template', Coreon.Templates["concepts/shared/associative_relations/edit"]

  describe "#render()", ->

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

    it "renders an icon for this type of relation", ->
      createAndRender()
      icon = el.find('td.icon')
      expect(icon).to.have.class 'see-also'

    it 'creates a concept label for each relation', ->
      relations.push {id: '1'}
      relations.push {id: '2'}
      createAndRender()
      expect(Coreon.Views.Concepts.ConceptLabelView).to.have.been.calledTwice

  describe "#onDrop()", ->

    beforeEach ->
      relations = []

    it 'adds a new dragged concept label in the relation list', ->
      label =
        data: (whatever) -> '1'
      sinon.stub view, 'checkIfExists', -> false
      sinon.stub view, 'render'
      view.onDrop('td.relations', label)
      expect(view.relations).to.have.lengthOf 1
      expect(view.render).to.have.been.CalledOnce

    it 'ignores an existing dragged concept label', ->
      label =
        data: (whatever) -> '1'
      sinon.stub view, 'checkIfExists', -> true
      sinon.stub view, 'render'
      view.onDrop('td.relations', label)
      expect(view.relations).to.have.lengthOf 0
      expect(view.render).to.not.have.been.Called

  describe "#onDisconnect()", ->

    it 'removes the dragged concept form the concept list', ->
      label =
        data: (whatever) -> '1'
        remove: sinon.spy
      concept = new Backbone.Model
      view.relations.push concept
      sinon.stub view, 'checkIfExists', -> concept
      sinon.stub view, 'render'
      view.onDisconnect(label)
      expect(view.relations).to.have.lengthOf 0
      expect(label.remove).to.have.been.CalledOnce
      expect(view.render).to.have.been.CalledOnce

  describe "#serializeArray()", ->

    it 'serializes all relations', ->
      model.relationType = { key: 'see also' }
      view.relations = [new Backbone.Model({id: '1'}),new Backbone.Model({id: '2'})]
      serialized = view.serializeArray()
      expect(serialized).to.have.lengthOf 2







