#= require spec_helper
#= require helpers/check_box_field

describe "Coreon.Helpers.checkBoxField()", ->

  helper = null
  options = null

  beforeEach ->
    helper = Coreon.Helpers.checkBoxField
    options = {}

  it 'renders a checkbox tag', ->
    markup = helper('Foo', 'bar')
    fieldset = $(markup)
    expect(fieldset).to.have 'input[type=checkbox]'

  describe 'checkbox', ->

    it 'has a name attribute', ->
      markup = helper('Foo', 'bar')
      checkbox = $(markup).find('input[type=checkbox]')
      expect(checkbox).to.have.attr 'name', 'bar'

    it 'has an id attribute', ->
      markup = helper('Foo', 'bar')
      checkbox = $(markup).find('input[type=checkbox]')
      expect(checkbox).to.have.attr 'name', 'bar'

    it 'does not have a required attribute by default', ->
      markup = helper('Foo', 'bar')
      checkbox = $(markup).find('input[type=checkbox]')
      expect(checkbox).to.not.have.attr 'required'

    it 'has a required attribute', ->
      markup = helper('Foo', 'bar', required: true)
      checkbox = $(markup).find('input[type=checkbox]')
      expect(checkbox).to.have.attr 'required'