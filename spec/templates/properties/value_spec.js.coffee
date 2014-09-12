#= require spec_helper
#= require templates/properties/value

describe 'Coreon.Templates[properties/value]', ->

  template = Coreon.Templates['properties/value']
  data = null

  render = -> $ template data

  beforeEach ->
    data =
      value: 'foo'

  it 'renders container', ->
    el = render()
    expect(el).to.have.class 'value'

  xit 'marks empty values', ->
    data.value = null
    el = render()
    expect(el).to.have.attr 'data-empty'