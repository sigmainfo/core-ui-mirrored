#= require spec_helper
#= require templates/properties/property_fieldset

describe 'Coreon.Templates[properties/property_fieldset]', ->

  template = Coreon.Templates['properties/property_fieldset']
  data = null
  model = null

  render = -> $ template data

  beforeEach ->
    model = new Backbone.Model
    data =
      input: sinon.stub()
      form_options: {}
      property:
        key: null
        value: null
        errors: []

  it 'renders container', ->
    el = render()
    expect(el).to.match 'fieldset.property'

  it 'renders a property key', ->
    data.property.key = 'somekey'
    data.input.withArgs(
      'property'
      , 'key'
      , null
      , errors: data.property.errors?.key
      , value: data.property.key
    )
    .returns '<input name="property[key]"/>'
    el = render()
    expect(el).to.have 'input[name="property[key]"]'

  it 'renders a property value', ->
    data.property.value = 'somevalue'
    data.input.withArgs(
      'property'
      , 'value'
      , null
      , errors: data.property.errors?.key
      , value: data.property.value
      , type: 'textarea'
    )
    .returns '<input name="property[value]"/>'
    el = render()
    expect(el).to.have 'input[name="property[value]"]'

  it 'renders property errors', ->
    data.property.errors = {key: ['is invalid']}
    data.input.withArgs(
      'property'
      , 'key'
      , null
      , errors: data.property.errors?.key
      , value: data.property.key
    )
    .returns '<input name="property[key]"/><p class="error">is invalid</p>'
    el = render()
    expect(el).to.contain 'is invalid'

  it 'renders a remove property link', ->
    data.input.withArgs(
      'property'
      , 'key'
      , null
    )
    .returns '<a>Remove</a><input name="property[key]"/>'
    el = render()
    expect(el).to.contain 'Remove'




