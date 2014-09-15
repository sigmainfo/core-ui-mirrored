#= require spec_helper
#= require templates/properties/value

describe 'Coreon.Templates[properties/value]', ->

  template = Coreon.Templates['properties/value']
  data = null

  render = -> $ template data

  beforeEach ->
    sinon.stub I18n, 'l'
    data =
      value: 'foo'
      type: 'text'

  afterEach ->
    I18n.l.restore()

  it 'renders container', ->
    el = render()
    expect(el).to.have.class 'value'

  it 'marks empty values', ->
    data.value = null
    el = render()
    expect(el).to.have.attr 'data-empty'

  it 'renders value', ->
    data.value = 'baz'
    el = render()
    expect(el).to.contain 'baz'

  context 'date', ->

    beforeEach ->
      data.type = 'date'

    it 'renders formated value', ->
      data.value = '2014-01-22 11:33'
      I18n.l.withArgs('2014-01-22 11:33').returns 'Jan 22, 2014'
      el = render()
      expect(el).to.contain 'Jan 22, 2014'

  context 'boolean', ->

    beforeEach ->
      data.type = 'boolean'

    it 'renders string representation', ->
      data.value = false
      el = render()
      expect(el).to.contain 'false'

  context 'picklist', ->

    values = (el) ->
      el.find '.picklist-item'

    beforeEach ->
      data.type = 'picklist'

    it 'renders picklist item', ->
      el = render()
      expect(values el).to.exist

    it 'renders value inside item', ->
      data.value = 'dangerous'
      el = render()
      expect(values el).to.have.text 'dangerous'

  context 'multiselect picklist', ->

    values = (el) ->
      el.find '.picklist-item'

    beforeEach ->
      data.type = 'multiselect_picklist'
      data.value = ['foo']

    it 'renders picklist items', ->
      data.value = ['first', 'second']
      el = render()
      expect(values el).to.have.lengthOf 2

    it 'renders values inside items', ->
      data.value = ['dangerous']
      el = render()
      expect(values el).to.have.text 'dangerous'

    it 'marks it as empty when no value is given', ->
      data.value = []
      el = render()
      expect(el).to.have.attr 'data-empty'

