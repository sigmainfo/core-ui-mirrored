#= require spec_helper
#= require views/concepts/shared/associative_relations_view

describe "Coreon.Views.Concepts.Shared.AssociativeRelationsView", ->

  view = null
  options = null
  collection = null
  el = null

  createAndRender = ->
    view = new Coreon.Views.Concepts.Shared.AssociativeRelationsView options
    el = view.render().$el

  beforeEach ->
    options =
      editing: false
      collection: collection
    view = new Coreon.Views.Concepts.Shared.AssociativeRelationsView options

  it "is a Backbone view", ->
    expect(view).to.be.an.instanceof Backbone.View

  it "has a section container", ->
    expect(view.$el).to.be "section"

  it "has a class", ->
    expect(view.$el).to.have.class "associative-relations"

  it "has a template", ->
    expect(view).to.have.property 'template', Coreon.Templates["concepts/shared/associative_relations"]

  describe "#render()", ->

    showViewStub = null
    editViewStub = null

    beforeEach ->
      options =
        collection: new Backbone.Collection([{},{}])
        editing: false
      showViewStub = sinon.stub Coreon.Views.Concepts.Shared.AssociativeRelations, 'ShowView', ->
        render: ->
          $el: $ markup
      editViewStub = sinon.stub Coreon.Views.Concepts.Shared.AssociativeRelations, 'EditView', ->
        render: ->
          $el: $ markup

    afterEach ->
      sinon.stub Coreon.Views.Concepts.Shared.AssociativeRelations.ShowView.restore()
      sinon.stub Coreon.Views.Concepts.Shared.AssociativeRelations.EditView.restore()

    it "renders a section title", ->
      createAndRender()
      expect(el).to.have "h3"
      view.$("h3").should.have.text "Associative Relations"

    context "show", ->

      it "renders views for each type of relation", ->
        options.editing = false
        createAndRender()
        expect(showViewStub).to.have.been.calledTwice
        expect(editViewStub).to.not.have.been.called

    context "edit", ->

      it "renders edit views for each type of relation", ->
        options.editing = true
        createAndRender()
        expect(showViewStub).to.not.have.been.called
        expect(editViewStub).to.have.been.calledTwice