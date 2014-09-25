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
        model: model
        errors: []

  it 'renders container', ->
    el = render()
    expect(el).to.match 'fieldset.property'

  it 'renders a property key', ->
    data.input.withArgs(
      'property'
      , 'key'
      , model
    )
    .returns '<input name="property[key]"/>'
    el = render()
    expect(el).to.have 'input[name="property[key]"]'

  it 'renders property errors', ->
    data.property.errors = {key: ['is invalid']}
    data.input.withArgs(
      'property'
      , 'key'
      , model
      , errors: data.property.errors?.key
    )
    .returns '<input name="property[key]"/><p class="error">is invalid</p>'
    el = render()
    expect(el).to.contain 'is invalid'

  it 'renders a remove property link', ->
    data.input.withArgs(
      'property'
      , 'key'
      , model
    )
    .returns '<a>Remove</a><input name="property[key]"/>'
    el = render()
    expect(el).to.contain 'Remove'


