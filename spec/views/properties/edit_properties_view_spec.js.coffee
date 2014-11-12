#= require spec_helper
#= require views/properties/edit_properties_view

describe 'Coreon.Views.Properties.EditPropertiesView', ->

  view = null
  collection = []
  optionalProperties = []
  isEdit = null
  collapsed = null

  newEditProperties = ->
    new Coreon.Views.Properties.EditPropertiesView
      collection: collection
      optionalProperties: optionalProperties
      isEdit: isEdit
      collapsed: collapsed

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

  afterEach ->
    I18n.t.restore()

  it 'is a Backbone view', ->
    view = newEditProperties()
    expect(view).to.be.an.instanceof Backbone.View

  it 'has a template', ->
    view = newEditProperties()
    expect(view).to.have.property 'template'

  describe '#initialize()', ->

    it 'initializes the view by passing an options hash', ->
      collection = [{key: 'description'}, {key: 'definition'}, {key: 'public'}]
      optionalProperties.push {key: 'label'}
      isEdit = true
      collapsed = false
      view = newEditProperties()
      expect(view).to.have.property 'collection'
      expect(view.collection[0]).to.have.property 'key', 'description'
      expect(view.fieldsetViews).to.have.lengthOf 3
      expect(view).to.have.property 'optionalProperties'
      expect(view.optionalProperties[0]).to.have.property 'key', 'label'
      expect(view).to.have.property 'isEdit', true
      expect(view).to.have.property 'collapsed', false

    it 'adds the apropriate classes to the view', ->
      isEdit = true
      collapsed = true
      view = newEditProperties()
      expect(view.$el).to.have.class 'edit'
      expect(view.$el).to.have.class 'collapsed'

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

    it 'renders a button to add new properties', ->
      el = renderView()
      expect(el).to.have 'a.add-property'

  describe "#serializeArray()", ->

    it 'returns an array of properties', ->
      view = new Coreon.Views.Properties.EditPropertiesView
        collection: collection
      fieldsetView1 = sinon.stub()
      fieldsetView1.serializeArray = -> [{key: 'value'}]
      fieldsetView2 = sinon.stub()
      fieldsetView2.serializeArray = -> [{key: 'other value'}, {key: 'yet another value'}]
      view.fieldsetViews = [fieldsetView1, fieldsetView2]
      serializedView = view.serializeArray()
      expect(serializedView).to.have.lengthOf 3
      expect(serializedView[0]).to.have.property 'key', 'value'
      expect(serializedView[1]).to.have.property 'key', 'other value'
      expect(serializedView[2]).to.have.property 'key', 'yet another value'









