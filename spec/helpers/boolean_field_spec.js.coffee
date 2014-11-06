#= require spec_helper
#= require helpers/boolean_field

describe "Coreon.Helpers.booleanField()", ->

  helper = null

  beforeEach ->
    helper = Coreon.Helpers.booleanField

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

  it 'has labels for each radio button', ->
    markup = helper('Foo', 'bar', labels: ['yes', 'no'])
    expect($(markup)).to.have "label:contains('yes')"
    expect($(markup)).to.have "label:contains('yes')"

  it 'pre-checks the true button if value is true', ->
    markup = helper('Foo', 'bar', labels: ['yes', 'no'], value: true)
    expect($(markup)).to.have "input[value=true]:checked"

  it 'pre-checks the false button if value is false', ->
    markup = helper('Foo', 'bar', labels: ['yes', 'no'], value: false)
    expect($(markup)).to.have "input[value=false]:checked"

  it 'does not check any radio if value not given', ->
    markup = helper('Foo', 'bar', labels: ['yes', 'no'])
    expect($(markup)).to.not.have "input:checked"