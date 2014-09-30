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
    data =
      input: sinon.stub()
      form_options: {}
      scope: null
      property:
        key: null
        value: null
        type: null
        errors: []

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

  it 'renders a remove property link', ->
    stubKey().returns '<a>Remove</a><input name="property[key]"/>'
    el = render()
    expect(el).to.contain 'Remove'

  it 'renders a select language for text properties', ->
    el = render()
    options = $(el).find('option').map( -> $(@).attr('value') ).get()
    expect(el).to.have 'select'
    expect(el).to.have '*[for=property-lang]'
    expect(options).to.eql ['en', 'de', 'fr']

  it 'doens\'t render a select language for non-text properties', ->
    data.property.type = 'boolean'
    el = render()
    expect(el).to.not.have 'select'

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






