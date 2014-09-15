#= require spec_helper
#= require templates/properties/value

describe 'Coreon.Templates[properties/value]', ->

  template = Coreon.Templates['properties/value']
  data = null

  render = -> $ template data

  beforeEach ->
    data =
      value: 'foo'
      type: 'text'

  it 'renders container', ->
    el = render()
    expect(el).to.have.class 'value'

  it 'renders a value', ->
    data.value = 'baz'
    el = render()
    expect(el).to.contain 'baz'

  it 'marks empty values', ->
    data.value = null
    el = render()
    expect(el).to.have.attr 'data-empty'

  context 'picklists', ->

    values = (el) ->
      el.find '.picklist-item'

    beforeEach ->
      data.value = ['foo']
      data.type = 'picklist'

    it 'renders picklist items', ->
      el = render()
      expect(values el).to.exist

    it 'renders value inside item', ->
      data.value = ['dangerous']
      el = render()
      expect(values el).to.have.text 'dangerous'

    it 'renders a list of values', ->
      data.value = ['foo', 'bar', 'baz']
      el = render()
      expect(values el).to.have.lengthOf 3
