#= require spec_helper
#= require helpers/multi_select_field

describe "Coreon.Helpers.multiSelectField()", ->

  helper = null

  beforeEach ->
    helper = Coreon.Helpers.multiSelectField

  it 'renders a list container', ->
    markup = helper('Foo', 'bar', options: [])
    fieldset = $(markup)
    expect(fieldset).to.have 'ul'

  it 'renders multiple checkboxes', ->
    markup = helper('Foo', 'bar', options: ['one', 'two'])
    fieldset = $(markup)
    checkboxes = fieldset.find('input[type=checkbox]')
    expect(checkboxes).to.have.lengthOf 2

  it 'puts a label on every checkbox', ->
    markup = helper('Foo', 'bar', options: ['one', 'two'])
    fieldset = $(markup)
    expect(fieldset).to.have 'label[for="bar_0"]'
    expect(fieldset).to.have 'label[for="bar_1"]'

  it 'puts a name attribute on every checkbox', ->
    markup = helper('Foo', 'bar', options: ['one', 'two'])
    fieldset = $(markup)
    expect(fieldset).to.have 'input[name="bar\[\]"]'
    expect(fieldset).to.have 'input[name="bar\[\]"]'

  it 'puts an id attribute on every checkbox', ->
    markup = helper('Foo', 'bar', options: ['one', 'two'])
    fieldset = $(markup)
    expect(fieldset).to.have 'input[id="bar_0"]'
    expect(fieldset).to.have 'input[id="bar_1"]'

  it 'puts a value attribute on every checkbox', ->
    markup = helper('Foo', 'bar', options: ['one', 'two'])
    fieldset = $(markup)
    expect(fieldset).to.have 'input[value=one]'
    expect(fieldset).to.have 'input[value=two]'














