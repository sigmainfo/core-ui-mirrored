#= require spec_helper
#= require templates/properties/property_fieldset

describe 'Coreon.Templates[properties/property_fieldset]', ->

  template = Coreon.Templates['properties/property_fieldset']
  data = null
  scope = null

  defaultLangs = [
    {
      key: 'en',
      short_name: 'en',
      name: 'English'
    },
    {
      key: 'de',
      short_name: 'de',
      name: 'German'
    },
    {
      key: 'fr',
      short_name: 'fr',
      name: 'French'
    }
  ]

  render = -> $ template data

  stubKey = ->
    data.textField.withArgs(
      I18n.t('property.key'),
      data.scope + '[properties][0][key]',
      value: data.property.key,
      required: true,
      errors: data.property.errors?.key,
      class: 'key'
    )


  stubValue = (type) ->
    data[type].withArgs(
      I18n.t('property.value'),
      data.scope + '[properties][0][value]',
      value: data.property.value,
      required: true,
      errors: data.property.errors?.value,
      class: 'value'
    )

  stubMultiValue = (type) ->
    data[type].withArgs(
      I18n.t('property.value'),
      data.scope + '[properties][0][value]',
      value: data.property.value,
      required: true,
      errors: data.property.errors?.value,
      class: 'value'
      options: data.property.options
    )

  beforeEach ->
    Coreon.application = new Backbone.Model
    Coreon.Models.RepositorySettings = sinon.stub
    Coreon.Models.RepositorySettings.languages = -> defaultLangs
    sinon.stub I18n, 't'
    data =
      index: 0
      input: sinon.stub()
      selectField: sinon.stub()
      textField: sinon.stub()
      textAreaField: sinon.stub()
      checkBoxField: sinon.stub()
      multiSelectField: sinon.stub()
      form_options: {}
      property:
        key: null
        value: null
        lang: null
        type: null
        errors: []
      index: 0
      scope: 'parent'
      selectableLanguages: []

  afterEach ->
    I18n.t.restore()

  it 'renders container', ->
    el = render()
    expect(el).to.match 'fieldset.property'

  it 'renders a property key', ->
    data.property.key = 'somekey'
    stubKey().returns '<input name="property[key]"/>'
    el = render()
    expect(el).to.have 'input[name="property[key]"]'

  it 'renders a property value', ->
    data.property.value = 'somevalue'
    stubValue('textAreaField').returns '<input name="property[value]"/>'
    el = render()
    expect(el).to.have 'input[name="property[value]"]'

  it 'renders property errors', ->
    data.property.errors = {key: ['is invalid']}
    stubKey().returns '<input name="property[key]"/><p class="error">is invalid</p>'

    el = render()
    expect(el).to.contain 'is invalid'

  # TODO 140930 [ap, tc] only applicable for custom props, do not render for defaults

  it 'renders a remove property link', ->
    stubKey().returns '<a>Remove</a><input name="property[key]"/>'
    el = render()
    expect(el).to.contain 'Remove'

  it 'renders language select', ->
    I18n.t.withArgs('forms.select.language').returns 'Language'
    data.selectableLanguages = [value: 'en', label: 'English']
    data.index = 3
    data.scope = 'concept'
    data.selectField.withArgs( 'Language'
                        , 'concept[properties][3][lang]'
                        , options: [value: 'en', label: 'English']
                        , allowEmpty: true
                        , class: 'lang'
                        )
      .returns '''
        <select id="concept-properties-3-langs">
          <option value="en">English</option>
        </select>
      '''
    el = render()
    expect(el).to.have 'select#concept-properties-3-langs'

  it 'renders select only when applicable', ->
    I18n.t.withArgs('forms.select.language').returns 'Language'
    delete data.property.lang
    data.selectField.withArgs('Language')
      .returns '''
        <select id="property-3-langs">
          <option value="en">English</option>
        </select>
      '''
    el = render()
    expect(el).to.not.have 'select#property-3-langs'

  describe 'renders the proper input for value according to property type', ->

    it 'renders a textarea by default', ->
      data.property.type = null
      stubValue('textAreaField').returns('<textarea></textarea>')
      el = render()
      expect(el).to.have 'textarea'

    it 'renders a checkbox for boolean type', ->
      data.property.type = 'boolean'
      stubValue('checkBoxField').returns('<input type="checkbox"/>')
      el = render()
      expect(el).to.have 'input[type=checkbox]'

    it 'renders nultiple checkboxs for multiselect_picklist type', ->
      data.property.type = 'multiselect_picklist'
      data.property.options = ['one', 'two']
      stubMultiValue('multiSelectField').returns('<input type="checkbox" name="one"/><input type="checkbox" name="two"/>')
      el = render()
      options = el.find 'input[type=checkbox]'
      expect(options).to.have.lengthOf 2







