#= require spec_helper
#= require views/properties/edit_properties_view

describe 'Coreon.Views.Properties.EditPropertiesView', ->

  view = null
  collection = []

  beforeEach ->
    i18n = sinon.stub I18n, 't'
    i18n.withArgs('properties.title').returns('Properties')
    Coreon.Models.RepositorySettings = sinon.stub
    Coreon.Models.RepositorySettings.languageOptions = ->
    [
      {value: 'en', label: 'English'},
      {value: 'de', label: 'German'},
      {value: 'fr', label: 'French'}
    ]
    view = new Coreon.Views.Properties.EditPropertiesView
      collection: collection

  afterEach ->
    I18n.t.restore()

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

    renderView = ->
      view = new Coreon.Views.Properties.EditPropertiesView
        collection: collection
      view.render()
      view.$el

    beforeEach ->
      collection = []

    it 'renders a title', ->
      el = renderView()
      expect(el).to.contain I18n.t('properties.title')

    it 'renders the fieldsets', ->
      collection = [{}, {}, {}]
      el = renderView()
      fieldsets = el.find 'fieldset'
      expect(fieldsets).to.have.lengthOf 3








