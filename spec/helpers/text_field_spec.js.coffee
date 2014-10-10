#= require spec_helper
#= require helpers/text_field

describe "Coreon.Helpers.textField()", ->

  helper = null
  options = null

  beforeEach ->
    helper = Coreon.Helpers.textField
    options = {}

  it 'renders a text input tag', ->
    markup = helper('Foo', 'bar')
    fieldset = $(markup)
    expect(fieldset).to.have 'input[type=text]'

  it 'has a name attribute', ->
    markup = helper('Foo', 'bar')
    text_input = $(markup).find('input[type=text]')
    expect(text_input).to.have.attr 'name', 'bar'

  it 'has an id attribute', ->
    markup = helper('Foo', 'bar')
    text_input = $(markup).find('input[type=text]')
    expect(text_input).to.have.attr 'name', 'bar'

  it 'does not have a required attribute by default', ->
    markup = helper('Foo', 'bar')
    text_input = $(markup).find('input[type=text]')
    expect(text_input).to.not.have.attr 'required'

  it 'has a required attribute', ->
    markup = helper('Foo', 'bar', required: true)
    text_input = $(markup).find('input[type=text]')
    expect(text_input).to.have.attr 'required'

  it 'has value when property value not empty', ->
    markup = helper('Foo', 'bar', value: 'This is a test.')
    text_input = $(markup).find('input[type=text]')
    expect(text_input).to.have.attr 'value', 'This is a test.'