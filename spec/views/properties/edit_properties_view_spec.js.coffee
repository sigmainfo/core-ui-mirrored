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

  renderView = ->
    view.render()
    view.$el

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

    it 'renders a title', ->
      view = newEditProperties()
      el = renderView()
      expect(el).to.contain I18n.t('properties.title')

    it 'renders the "add property" pop-up', ->
      view = newEditProperties()
      sinon.stub view, 'renderAddPropertyPopUp'
      el = renderView()
      expect(view.renderAddPropertyPopUp).to.have.been.calledOnce

    it 'renders the fieldsets', ->
      collection = [{}, {}, {}]
      view = newEditProperties()
      el = renderView()
      fieldsets = el.find 'fieldset'
      expect(fieldsets).to.have.lengthOf 3

    it 'renders a button to add new properties', ->
      view = newEditProperties()
      el = renderView()
      expect(el).to.have 'a.add-property'

  describe '#renderAddPropertyPopUp()', ->

    it 'creates a hidden select popup for optional properties', ->
      view = newEditProperties()
      view.$el = $ '''
        <section>
          <h3 class="title">Title</h3>
          <div class="add">
            <div class="edit">
              <a class="add-property" href="javascript:void(0)">Add property</a>
            </div>
          </div>
        </section>
      '''
      view.renderAddPropertyPopUp()
      popUp = view.$el.find('.coreon-select.widget-select[data-select-name=chooseProperty]')
      expect(popUp).to.be.hidden

  describe '#remainingOptionalProperties()', ->

    it 'collects unused blueprint properties', ->
      optionalProperties = [{key: 'label'}, {key: 'definition'}, {key: 'public'}]
      collection = [{key: 'definition'}]
      view = newEditProperties()
      remaining = view.remainingOptionalProperties()
      expect(remaining).to.have.lengthOf 2
      expect(remaining).to.deep.equal [{key: 'label'}, {key: 'public'}]

  describe '#isValid()', ->

    it 'returns true when all fieldsets are valid', ->
      view = newEditProperties()
      view.fieldsetViews = [{isValid: -> true}, {isValid: -> true}]
      expect(view.isValid()).to.be.true

    it 'returns false when even one of the fieldsets is invalid', ->
      view = newEditProperties()
      view.fieldsetViews = [{isValid: -> false}, {isValid: -> true}]
      expect(view.isValid()).to.be.false


  describe '#serializeArray()', ->

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

  describe '#countDeleted()', ->

    it 'counts fieldsets marked as deleted', ->
      view = newEditProperties()
      view.fieldsetViews = [{checkDelete: -> false}, {checkDelete: -> true}, {checkDelete: -> true}]
      expect(view.countDeleted()).to.equal 2

  describe '#addProperty()', ->

    event = null
    listen = null
    newFieldsetView = null
    spy = null

    beforeEach ->
      collection = []
      optionalProperties = [{key: 'label'}]
      Coreon.Models.Property = sinon.stub
      Coreon.Formatters.PropertiesFormatter = ->
        all: -> [{key: 'label'}]
      view = newEditProperties()
      el = renderView()
      event = $.Event()
      event.target = '<select><option value="label" selected>Label</option></select>'
      listen = sinon.stub view, 'listenTo'
      sinon.spy Coreon.Views.Properties, "PropertyFieldsetView"
      sinon.stub view, 'renderAddPropertyPopUp'
      sinon.stub view, 'updateValid'
      view.addProperty(event)

    afterEach ->
      Coreon.Views.Properties.PropertyFieldsetView.restore()

    it 'creates a new property fieldset', ->
      expect(Coreon.Views.Properties.PropertyFieldsetView).to.have.been.calledWithNew

    it 'starts listening to the new property fieldsets for changes', ->
      firstCall = listen.getCall(0)
      secondCall = listen.getCall(1)
      expect(firstCall.args[1]).to.equal 'inputChanged'
      expect(secondCall.args[1]).to.equal 'removeProperty'

    it 'raises the next property fieldset index by 1', ->
      expect(view.index).to.equal 1

    it 'adds the new view to the fieldsetViews array', ->
      expect(view.fieldsetViews).to.have.lengthOf 1

    it 'renders the new view', ->
      expect(view.$('fieldset')).to.have.lengthOf 1

    it 'refreshes the optional properties pop-up', ->
      expect(view.renderAddPropertyPopUp).to.have.been.calledOnce

    it 'triggers a re-validation', ->
      expect(view.updateValid).to.have.been.calledOnce

  describe '#removeProperty()', ->

    it 'marks the property as deleted if there are persistent values in the fieldset', ->
      collection = [{key: 'label'}]
      view = newEditProperties()
      fieldsetView = view.fieldsetViews[0]
      sinon.stub(fieldsetView, 'containsPersisted').returns true
      sinon.stub(fieldsetView, 'markDelete')
      view.removeProperty fieldsetView
      expect(fieldsetView.markDelete).to.have.been.calledOnce
      expect(view.fieldsetViews).to.have.lengthOf 1

    it 'removes the property as deleted if there are no persistent values in the fieldset', ->
      collection = [{key: 'label'}]
      view = newEditProperties()
      fieldsetView = view.fieldsetViews[0]
      sinon.stub(fieldsetView, 'containsPersisted').returns false
      sinon.stub(fieldsetView, 'remove')
      view.removeProperty fieldsetView
      expect(fieldsetView.remove).to.have.been.calledOnce
      expect(view.fieldsetViews).to.have.lengthOf 0













