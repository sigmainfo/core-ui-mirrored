#= require spec_helper
#= require helpers/text_area_field

describe "Coreon.Helpers.textAreaField()", ->

  helper = null
  options = null

  beforeEach ->
    helper = Coreon.Helpers.textAreaField
    options = {}

  it 'renders a textarea tag', ->
    markup = helper('Foo', 'bar')
    fieldset = $(markup)
    expect(fieldset).to.have 'textarea'

  it 'has a name attribute', ->
    markup = helper('Foo', 'bar')
    textarea = $(markup).find('textarea')
    expect(textarea).to.have.attr 'name', 'bar'

  it 'has an id attribute', ->
    markup = helper('Foo', 'bar')
    textarea = $(markup).find('textarea')
    expect(textarea).to.have.attr 'name', 'bar'

  it 'does not have a required attribute by default', ->
    markup = helper('Foo', 'bar')
    textarea = $(markup).find('textarea')
    expect(textarea).to.not.have.attr 'required'

  it 'has a required attribute', ->
    markup = helper('Foo', 'bar', required: true)
    textarea = $(markup).find('textarea')
    expect(textarea).to.have.attr 'required'

  it 'has content when property value not empty', ->
    markup = helper('Foo', 'bar', value: 'This is a test.')
    textarea = $(markup).find('textarea')
    expect(textarea).to.contain 'This is a test.'