#= require spec_helper
#= require views/panels/terms/term_view

describe 'Coreon.Views.Panels.Terms.TermView', ->

  view = null
  model = null

  beforeEach ->
    model = new Backbone.Model
    model.info = ->
    view = new Coreon.Views.Panels.Terms.TermView model: model

  afterEach ->
    #Coreon.Helpers.can.restore()

  it 'is a backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'has a container', ->
    el = view.$el
    expect(el).to.match 'li.term'

  describe '#render()', ->

    canStub = null

    beforeEach ->
      model.set 'value', 'test'
      sinon.stub Coreon.Templates, 'concepts/info'
      canStub = sinon.stub Coreon.Helpers, 'can'
      canStub.returns true

    afterEach ->
      Coreon.Templates['concepts/info'].restore()
      Coreon.Helpers.can.restore()

    it "renders the term's value", ->
      el = view.render().$el
      value = view.$('h4.value')
      expect(value).to.contain 'test'

    it "renders the term's info", ->
      model.info = -> {id: '#1234'}
      Coreon.Templates['concepts/info'].withArgs(data: id: '#1234')
        .returns '<div class="system-info">id: #1234</div>'
      el = view.render().$el
      info = view.$('.system-info')
      expect(info).to.contain 'id: #1234'

    it "renders the term's properties", ->
      model.set 'properties', [{}, {}]
      model.propertiesWithDefaults = -> [{}, {}]
      renderPropertiesStub = sinon.stub(Coreon.Helpers, 'render').withArgs "concepts/properties",
        properties: model.propertiesWithDefaults(),
        collapsed: true,
        noEditButton: true
      el = view.render().$el
      expect(renderPropertiesStub).to.have.been.calledOnce

    it "renders a delete button for term if user is allowed to delete the term", ->
      el = view.render().$el
      expect(el).to.have 'a.remove-term'

    it "does not render a delete button for term if user is not allowed to delete the term", ->
      canStub.returns false
      el = view.render().$el
      expect(el).to.not.have 'a.remove-term'

    it "renders an edit button for term if user is allowed to edit the term", ->
      el = view.render().$el
      expect(el).to.have 'a.edit-term'

    it "does not render an edit button for term if user is not allowed to edit the term", ->
      canStub.returns false
      el = view.render().$el
      expect(el).to.not.have 'a.edit-term'