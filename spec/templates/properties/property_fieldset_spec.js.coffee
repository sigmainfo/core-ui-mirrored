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

  it 'renders container', ->
    el = render()
    expect(el).to.match 'fieldset.property'

  it 'renders a property key', ->
    data.form_options =
      scope: 'concept[properties][]'
    data.input.withArgs(
      'property'
      , 'key'
      , model
      , data.form_options
    )
    .returns '<input name="property[key]"/>'
    el = render()
    expect(el).to.have 'input[name="property[key]"]'
