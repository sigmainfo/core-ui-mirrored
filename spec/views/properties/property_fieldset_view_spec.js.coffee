#= require spec_helper
#= require views/properties/property_fieldset_view
#= require templates/properties/property_fieldset

describe 'Coreon.Views.Properties.PropertyFieldsetView', ->

  view = null
  el = null
  model = null

  beforeEach ->
    sinon.stub I18n, 't'

  afterEach ->
    I18n.t.restore()

  it 'is a Backbone view', ->
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model
    expect(view).to.be.an.instanceof Backbone.View

  it 'has a template', ->
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model
    expect(view).to.have.property 'template'

  describe '#render()', ->

    renderView = ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      view.render()
      view.$el

    beforeEach ->
      model =
        key: 'label'
        type: 'text'
        properties: [
            value: 'car'
            lang: 'en'
            errors: {}
          ]

    it 'renders container', ->
      el = renderView()
      expect(el).to.match 'fieldset.property'

    it 'renders the property key as a title', ->
      model.key = 'my_key'
      el = renderView()
      title = el.find 'h2'
      expect(title).to.contain 'my_key'

    it 'renders the property key as a title', ->
      model.key = 'my_key'
      el = renderView()
      title = el.find 'h2'
      expect(title).to.contain 'my_key'

    it 'renders a remove property link', ->
      I18n.t.withArgs('property.remove').returns 'Remove'
      el = renderView()
      removeLink = el.find 'a.remove-property'
      expect(removeLink).to.contain 'Remove'

    describe 'renders the proper input for value according to property type', ->

      it 'renders a text input field for type text', ->
        model.type = 'text'
        fail


    xit 'renders property errors', ->
      model.errors = {value: ['is invalid']}
      el = renderView()
      expect(el).to.contain 'is invalid'


