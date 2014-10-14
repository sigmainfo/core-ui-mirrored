#= require spec_helper
#= require templates/properties/edit_properties

describe 'Coreon.Templates[properties/edit_properties]', ->

  template = Coreon.Templates['properties/edit_properties']
  data = null
  i18n = null

  render = -> $ template data

  beforeEach ->
    i18n = sinon.stub I18n, 't'
    i18n.withArgs('properties.title').returns('Properties')
  #   data =
  #     value: 'foo'
  #     type: 'text'

  afterEach ->
    I18n.t.restore()

  it 'renders a title', ->
    el = render()
    expect(el).to.contain I18n.t('properties.title')