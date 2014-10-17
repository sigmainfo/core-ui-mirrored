#= require spec_helper
#= require views/properties/edit_properties_view

describe 'Coreon.Views.Properties.EditPropertiesView', ->

  view = null
  collection = []

  beforeEach ->
    view = new Coreon.Views.Properties.EditPropertiesView
      collection: collection

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceof Backbone.View

  it 'has a template', ->
    expect(view).to.have.property 'template'

  describe '#initialize()', ->

    it 'creates a collection of fieldset views', ->
      expect(view).to.have.property 'fieldsetViews'

    it 'populates the fiedlset view collection with fieldset views', ->
      collection = [{}, {}, {}]
      view = new Coreon.Views.Properties.EditPropertiesView
        collection: collection
      expect(view.fieldsetViews).to.have.lengthOf 3

  describe '#render()', ->

    renderSpy = null

    beforeEach ->
      collection = [{}, {}, {}]
      view = new Coreon.Views.Properties.EditPropertiesView
        collection: collection
      sinon.stub view, 'template'
      renderSpy = sinon.spy Coreon.Views.Properties.PropertyFieldsetView.prototype, 'render'

    afterEach ->
      view.template.restore()
      Coreon.Views.Properties.PropertyFieldsetView.prototype.render.restore()

    it 'renders the template', ->
      view.render()
      expect(view.template).to.have.been.calledOnce

    it 'renders the fieldsets', ->
      view.render()
      expect(renderSpy).to.have.been.called.thrice








