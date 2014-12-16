#= require spec_helper
#= require views/panels/terms/term_view

describe 'Coreon.Views.Panels.Terms.TermView', ->

  view = null
  model = null

  beforeEach ->
    Coreon.application = sinon.stub
    Coreon.application.repositorySettings = ->
      new Backbone.Model(
        propertiesCollapsed: true
      )
    model = new Backbone.Model
    model.info = ->
    view = new Coreon.Views.Panels.Terms.TermView model: model

  it 'is a backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'has a container', ->
    el = view.$el
    expect(el).to.match 'li.term'

  describe '#render()', ->

    canStub = null
    renderStub = null

    beforeEach ->
      model.set 'value', 'test'
      canStub = sinon.stub Coreon.Helpers, 'can'
      canStub.returns true
      renderStub = sinon.stub(Coreon.Helpers, 'render')

    afterEach ->
      Coreon.Helpers.can.restore()
      Coreon.Helpers.render.restore()

    it "renders the term's value", ->
      el = view.render().$el
      value = view.$('h4.value')
      expect(value).to.contain 'test'

    it "renders the term's info", ->
      model.info = -> {id: '#1234'}
      renderStub.withArgs("concepts/info", data: id: '#1234')
        .returns '<div class="system-info">id: #1234</div>'
      el = view.render().$el
      info = view.$('.system-info')
      expect(info).to.contain 'id: #1234'

    it "renders the term's properties", ->
      model.set 'properties', [{}, {}]
      model.propertiesWithDefaults = -> [{}, {}]
      propertiesStub = renderStub.withArgs "concepts/properties",
        properties: model.propertiesWithDefaults(),
        collapsed: true,
        noEditButton: true
      el = view.render().$el
      expect(propertiesStub).to.have.been.calledOnce

    it "renders the term's properties expanded if repository setting exists", ->
      Coreon.application.repositorySettings = ->
        new Backbone.Model(
          propertiesCollapsed: false
        )
      model.set 'properties', [{}, {}]
      model.propertiesWithDefaults = -> [{}, {}]
      propertiesStub = renderStub.withArgs "concepts/properties",
        properties: model.propertiesWithDefaults(),
        collapsed: false,
        noEditButton: true
      el = view.render().$el
      expect(propertiesStub).to.have.been.calledOnce

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

  describe '#removeTerm()', ->

    canStub = null

    beforeEach ->
      model.set 'value', 'test'
      sinon.stub Coreon.Templates, 'concepts/info'
      canStub = sinon.stub Coreon.Helpers, 'can'
      canStub.returns true

    afterEach ->
      Coreon.Templates['concepts/info'].restore()
      Coreon.Helpers.can.restore()

    it 'is triggered by clicking on remove link', ->
      sinon.stub view, 'removeTerm'
      $('#konacha').append view.render().$el
      view.delegateEvents()
      view.$('a.remove-term').click()
      expect(view.removeTerm).to.have.been.calledOnce

    it 'renders a confirm dialog', ->
      sinon.stub view, 'confirm'
      view.render()
      evt = $.Event
      evt.target = $('.remove-term')
      view.removeTerm(evt)
      expect(view.confirm).to.have.been.calledOnce

