#= require spec_helper
#= require helpers/boolean_field

describe "Coreon.Helpers.booleanField()", ->

  helper = null
  options = null

  beforeEach ->
    helper = Coreon.Helpers.booleanField
    options = {}

  it 'renders two input radio tags', ->
    markup = helper('Foo', 'bar')
    radios = $(markup).find 'input[type=radio]'
    expect(radios).to.have.lengthOf 2

  it 'has a name attribute', ->
    markup = helper('Foo', 'bar')
    radios = $(markup).find 'input[type=radio]'
    expect($(radios[0])).to.have.attr 'name', 'bar'
    expect($(radios[1])).to.have.attr 'name', 'bar'

  it 'has an id attribute', ->
    markup = helper('Foo', 'bar')
    radios = $(markup).find 'input[type=radio]'
    expect($(radios[0])).to.have.attr 'id', 'bar_0'
    expect($(radios[1])).to.have.attr 'id', 'bar_1'