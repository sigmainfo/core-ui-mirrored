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
    view = new Coreon.Views.Concepts.Shared.AssociativeRelations.ShowView model: model

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

    # it "renders an empty div when no relations exist", ->
    #   createAndRender()
    #   relations = el.find('td > ul')
    #   expect(relations).to.not.have '.relation'

    # it "renders an relation objects when relations exist", ->
    #   relations.push {id: '2'}
    #   relations.push {id: '3'}
    #   createAndRender()
    #   expect(el).to.have 'li.relation'
    #   relations = el.find('li.relation')
    #   expect(relations).to.have.lengthOf 2