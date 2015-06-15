#= require spec_helper
#= require views/concepts/shared/associative_relations_view

describe "Coreon.Views.Concepts.Shared.AssociativeRelationsView", ->

  view = null
  options = null
  collection = null
  el = null
  markup = null

  createAndRender = (editing) ->
    Coreon.application =
      repositorySettings: ->
        []
    view = new Coreon.Views.Concepts.Shared.AssociativeRelationsView options
    view.editing = on if editing
    el = view.render().$el

  beforeEach ->

    options =
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
        collection: [{relations: [{id: 1}]},{}]
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
      view.$("h3").should.have.text "Associated"

    it "renders a hidden edit section", ->
      createAndRender()
      expect(el).to.have ".edit"

    context "show", ->

      it "renders views for each type of relation", ->
        createAndRender()
        expect(showViewStub).to.have.been.calledOnce
        expect(editViewStub).to.not.have.been.called
        expect($(view.el)).not.to.have 'form'

    context "edit", ->

      it "renders edit views for each type of relation", ->
        sinon.stub Coreon.Helpers, 'form_for', ->
          '<form></form>'
        createAndRender(true)
        expect(showViewStub).to.not.have.been.called
        expect(editViewStub).to.have.been.calledTwice
        expect($(view.el)).to.have 'form'