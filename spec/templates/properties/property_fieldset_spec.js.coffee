#= require spec_helper
#= require templates/properties/property_fieldset

describe 'Coreon.Templates[properties/property_fieldset]', ->

  template = Coreon.Templates['properties/property_fieldset']
  data = null

  render = -> $ template data

  beforeEach ->
    data =
      input: sinon.stub()
      property:
        value: 'foo'
        default: yes
        model: new Backbone.Model


  it 'renders container', ->
    el = render()
    expect(el).to.match 'fieldset.property'

  it 'renders a property key', ->
    data.input.withArgs('property', 'key', data.property.model)
      .returns '<input name="property[key]"/>'
    el = render()
    expect(el).to.have 'input[name="property[key]"]'