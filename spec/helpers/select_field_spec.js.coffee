#= require spec_helper
#= require helpers/select_field

describe "Coreon.Helpers.selectField()", ->

  helper = null
  options = null

  beforeEach ->
    helper = Coreon.Helpers.selectField
    options = {}

  it 'renders a select tag', ->
    markup = helper('Foo', 'bar')
    fieldset = $(markup)
    expect(fieldset).to.have 'select'

  it 'has a name attribute', ->
    markup = helper('Foo', 'bar')
    select = $(markup).find('select')
    expect(select).to.have.attr 'name', 'bar'

  it 'has an id attribute', ->
    markup = helper('Foo', 'bar')
    select = $(markup).find('select')
    expect(select).to.have.attr 'name', 'bar'

  it 'does not have a required attribute by default', ->
    markup = helper('Foo', 'bar')
    select = $(markup).find('select')
    expect(select).to.not.have.attr 'required'

  it 'has a required attribute', ->
    markup = helper('Foo', 'bar', required: true)
    select = $(markup).find('select')
    expect(select).to.have.attr 'required'

  it 'renders given options', ->
    select_options = [
      {value: 'en', label: 'English'},
      {value: 'de', label: 'German'}
    ]
    markup = helper('Foo', 'bar', options: select_options)
    select = $(markup).find('select')
    options = select.find('option')
    expect(options).to.have.lengthOf 2
    expect(options.first()).to.have.attr 'value', 'en'
    expect(options.first()).to.have.contain 'English'
    expect(options.last()).to.have.attr 'value', 'de'
    expect(options.last()).to.have.contain 'German'

  it 'renders empty option if requested', ->
    select_options = [value: 'en', label: 'English']
    markup = helper('Foo', 'bar', options: select_options, allowEmpty: true)
    select = $(markup).find('select')
    options = select.find('option')
    expect(options).to.have.lengthOf 2

  it 'the relative options is selected when value not empty', ->
    select_options = [
      {value: 'en', label: 'English'},
      {value: 'de', label: 'German'}
    ]
    markup = helper('Foo', 'bar', options: select_options, value: 'de')
    select = $(markup).find('select')
    options = select.find('option:selected')
    expect(options).to.have.attr 'value', 'de'












