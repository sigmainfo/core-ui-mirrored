#= require spec_helper
#= require helpers/select_field

describe "Coreon.Helpers.selectField()", ->

  helper = null
  options = null

  beforeEach ->
    helper = Coreon.Helpers.selectField
    options = {}

  it 'renders a container', ->
    markup = helper('Foo', 'bar')
    fieldset = $(markup)
    expect(fieldset).to.match 'div'

  it 'renders a select tag', ->
    markup = helper('Foo', 'bar')
    fieldset = $(markup)
    expect(fieldset).to.have 'select'

  it 'renders a label', ->
    markup = helper('Foo', 'bar')
    fieldset = $(markup)
    expect(fieldset).to.contain 'Foo'

  it 'renders the given class name', ->
    markup = helper('Foo', 'bar', class: 'myclass')
    fieldset = $(markup)
    expect(fieldset).to.match 'div.myclass'

  describe 'select', ->

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
      options = [
        {value: 'en', label: 'English'},
        {value: 'de', label: 'German'}
      ]
      markup = helper('Foo', 'bar', options: options)
      select = $(markup).find('select')
      options = select.find('option')
      expect(options).to.have.lengthOf 2
      expect(options.first()).to.have.attr 'value', 'en'
      expect(options.first()).to.have.contain 'English'
      expect(options.last()).to.have.attr 'value', 'de'
      expect(options.last()).to.have.contain 'German'

    it 'renders empty option if requested', ->
      options = [value: 'en', label: 'English']
      markup = helper('Foo', 'bar', options: options, allowEmpty: true)
      select = $(markup).find('select')
      options = select.find('option')
      expect(options).to.have.lengthOf 2

  describe 'errors', ->

    it 'renders errors if any', ->
      markup = helper('Foo', 'bar', errors: ['an error!'])
      fieldset = $(markup)
      expect(fieldset).to.have '.error-message'

    it 'doesn\'t render errors if not any', ->
      markup = helper('Foo', 'bar')
      fieldset = $(markup)
      expect(fieldset).to.not.have '.error-message'












