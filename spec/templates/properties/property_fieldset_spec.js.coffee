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
    data.input.withArgs(
      'property'
      , 'key'
      , null
      , errors: data.property.errors?.key
      , value: data.property.key
      , scope: scope
    )


  stubValue = (type) ->
    data.input.withArgs(
      'property'
      , 'value'
      , null
      , errors: data.property.errors?.key
      , value: data.property.value
      , scope: scope
      , type: type
    )

  beforeEach ->
    Coreon.application = new Backbone.Model
    Coreon.Models.RepositorySettings = sinon.stub
    Coreon.Models.RepositorySettings.languages = -> defaultLangs
    sinon.stub I18n, 't'
    data =
      input: sinon.stub()
      selectField: sinon.stub()
      form_options: {}
      scope: null
      property:
        key: null
        value: null
        lang: null
        type: null
        errors: []
      index: 0
      namePrefix: ''
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
    stubValue('textarea').returns '<input name="property[value]"/>'
    el = render()
    expect(el).to.have 'input[name="property[value]"]'

  it 'renders the scope for key', ->
    data.property.scope = 'concept[properties][]'
    stubKey().returns '<input name="concept[properties][0][key]"/>'
    el = render()
    expect(el).to.have 'input[name="concept[properties][0][key]"]'

  it 'renders the scope for value', ->
    data.property.scope = 'concept[properties][]'
    stubValue('textarea').returns '<input name="concept[properties][0][value]"/>'
    el = render()
    expect(el).to.have 'input[name="concept[properties][0][value]"]'

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
    data.namePrefix = 'concept'
    data.selectField.withArgs( 'Language'
                        , 'concept[properties][3][lang]'
                        , options: [value: 'en', label: 'English']
                        )
      .returns '''
        <select id="property-3-langs">
          <option value="en">English</option>
        </select>
      '''
    el = render()
    expect(el).to.have 'select#property-3-langs'

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
      stubValue('textarea').returns('<textarea></textarea>')
      el = render()
      expect(el).to.have 'textarea'

    it 'renders a checkbox for boolean type', ->
      data.property.type = 'boolean'
      stubValue('checkbox').returns('<input type="checkbox"/>')
      el = render()
      expect(el).to.have 'input[type=checkbox]'






