#= require spec_helper
#= require views/properties/property_fieldset_view
#= require templates/properties/property_fieldset

describe 'Coreon.Views.Properties.PropertyFieldsetView', ->

  view = null
  el = null
  model = null
  index = 0
  scopePrefix = null

  beforeEach ->
    sinon.stub I18n, 't'
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
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model
    expect(view).to.be.an.instanceof Backbone.View

  it 'has a template', ->
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model
    expect(view).to.have.property 'template'

  it 'accepts extra options', ->
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: 2, scopePrefix: 'concept'
    expect(view).to.have.property 'index', 2
    expect(view).to.have.property 'scopePrefix', 'concept'

  it 'creates a name for the field', ->
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: 2
    expect(view).to.have.property 'name', 'properties[2]'

  it 'creates a name for the field', ->
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: 2
    expect(view).to.have.property 'name', 'properties[2]'

  it 'creates a name for the field using scopePrefix if given', ->
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: 3, scopePrefix: 'concept'
    expect(view).to.have.property 'name', 'concept[properties][3]'

  describe '#render()', ->

    renderView = ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
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
      title = el.find 'h4'
      expect(title).to.contain 'my_key'

    it 'renders a remove value link for multivalued fieldsets', ->
      I18n.t.withArgs('property.value.remove', {property_name: model.key}).returns 'Remove value'
      el = renderView()
      removeLink = el.find 'a.remove-value'
      expect(removeLink).to.contain 'Remove value'

    it 'does not renders a remove value link for non-multivalued fieldsets', ->
      model.type = 'boolean'
      el = renderView()
      expect(el).to.not.contain 'a.remove-value'

    it 'renders a remove property link for non multivalued fieldsets', ->
      model.type = 'boolean'
      I18n.t.withArgs('property.remove', {property_name: model.key}).returns 'Remove property'
      el = renderView()
      removeLink = el.find 'a.remove-property'
      expect(removeLink).to.contain 'Remove property'

    xit 'renders property errors', ->
      model.errors = {value: ['is invalid']}
      el = renderView()
      expect(el).to.contain 'is invalid'

    describe 'renders the proper input for value according to property type', ->

      context 'text fields', ->

        textFieldStub = null

        beforeEach ->
          textFieldStub = sinon.stub(Coreon.Helpers, 'textField')
          sinon.stub(Coreon.Helpers, 'selectField').returns '''
              <select>
                <option value="en">English</option>
                <option value="de">German</option>
                <option value="fr">French</option>
              </select>
            '''


        afterEach ->
          Coreon.Helpers.textField.restore()
          Coreon.Helpers.selectField.restore()

        it 'renders a text input field for type text', ->
          textFieldStub.withArgs(
            null,
            'properties[0][0][value]',
            value: 'car',
            required: true, errors: {}, class: 'value'
          ).returns('<input type="text"></input>')
          model.type = 'text'
          el = renderView()
          expect(el).to.have 'input[type=text]'
          expect(el).to.have 'select'

        it 'renders multiple text input fields when given', ->
          textFieldStub.withArgs(
            null,
            'properties[0][0][value]',
            value: 'car',
            required: true,
            errors: {},
            class: 'value'
          ).returns('<input type="text"></input>')
          textFieldStub.withArgs(
            null,
            'properties[0][1][value]',
            value: 'auto',
            required: true,
            errors: {},
            class: 'value'
          ).returns('<input type="text"></input>')
          model.type = 'text'
          model.properties.push {
            value: 'auto'
            lang: 'de'
            errors: {}
          }
          el = renderView()
          inputs = el.find 'input[type=text]'
          langSelects = el.find 'select'
          expect(inputs).to.have.lengthOf 2
          expect(langSelects).to.have.lengthOf 2

      context 'boolean fields', ->

        booleanFieldStub = null

        beforeEach ->
          booleanFieldStub = sinon.stub(Coreon.Helpers, 'booleanField')

        afterEach ->
          Coreon.Helpers.booleanField.restore()

        it 'renders a text input field for type boolean', ->
          model.type = 'boolean'
          model.labels = ['Yes', 'No']
          model.properties[0].value = true
          booleanFieldStub.withArgs(
            null,
            'properties[0][value]',
            value: true,
            required: true,
            errors: {},
            labels: ['Yes', 'No'],
            class: 'value'
          ).returns('<input type="radio">yes</input><input type="radio">no</input>')
          el = renderView()
          expect(el).to.have 'input[type=radio]'
          expect(el).not.to.have 'select'

    describe '#value()', ->

      context 'for text property', ->

        it 'returns the values of each set property', ->
          model.type = 'text'
          model.key = 'car'
          markup = $ '''
              <fieldset>
                <div class="group">
                  <input type="text">
                  <select><option value="en" selected="">English</option></select>
                </div>
                <div class="group">
                  <input type="text">
                  <select><option value="de" selected="">German</option></select>
                </div>
              </fieldset>
            '''
          view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
          view.$el = markup
          view.$el.find('input').first().val("Honda")
          view.$el.find('input').last().val("Mazda")
          properties = view.serializeArray()
          expect(properties).to.have.lengthOf 2
          expect(properties[0]).to.have.property 'value', 'Honda'
          expect(properties[1]).to.have.property 'value', 'Mazda'





