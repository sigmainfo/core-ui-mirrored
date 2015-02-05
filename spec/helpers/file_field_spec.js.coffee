#= require spec_helper
#= require helpers/file_field

describe "Coreon.Helpers.fileField()", ->

  helper = null
  options = null

  beforeEach ->
    helper = Coreon.Helpers.fileField
    options = {}

  it 'renders a file input tag', ->
    markup = helper('Foo', 'bar')
    fieldset = $(markup)
    expect(fieldset).to.have 'input[type=file]'

  it 'has a name attribute', ->
    markup = helper('Foo', 'bar')
    text_input = $(markup).find('input[type=file]')
    expect(text_input).to.have.attr 'name', 'bar'

  it 'has an id attribute', ->
    markup = helper('Foo', 'bar')
    text_input = $(markup).find('input[type=file]')
    expect(text_input).to.have.attr 'name', 'bar'

  it 'does not have a required attribute by default', ->
    markup = helper('Foo', 'bar')
    text_input = $(markup).find('input[type=file]')
    expect(text_input).to.not.have.attr 'required'

  it 'has a required attribute', ->
    markup = helper('Foo', 'bar', required: true)
    text_input = $(markup).find('input[type=file]')
    expect(text_input).to.have.attr 'required'