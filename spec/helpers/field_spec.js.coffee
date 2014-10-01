#= require spec_helper
#= require helpers/field

describe 'Coreon.Helpers.Field', ->

  template = null

  it 'has a label attribute', ->
    field = new Coreon.Helpers.Field 'foo', 'bar', template, {}
    expect(field).to.have.property 'label', 'foo'

  it 'has a name attribute', ->
    field = new Coreon.Helpers.Field 'foo', 'bar', template, {}
    expect(field).to.have.property 'name', 'bar'

  it 'generates and id from name if not given', ->
    field = new Coreon.Helpers.Field 'foo', 'bar[cool]', template, {}
    expect(field).to.have.property 'id', 'bar_cool_'

  describe 'options', ->

    options = null

    beforeEach ->
      options = {}

    it 'sets the id given in options as a property', ->
      options.id = 'kaboom'
      field = new Coreon.Helpers.Field 'foo', 'bar[cool]', template, options
      expect(field).to.have.property 'id', 'kaboom'

    it 'sets the id given in options as a property', ->
      options.id = 'kaboom'
      field = new Coreon.Helpers.Field 'foo', 'bar', template, options
      expect(field).to.have.property 'id', 'kaboom'

    it 'sets the required property to false by default', ->
      field = new Coreon.Helpers.Field 'foo', 'bar', template, options
      expect(field).to.have.property 'required', off

    it 'sets the required property to true when given', ->
      options.required = true
      field = new Coreon.Helpers.Field 'foo', 'bar', template, options
      expect(field).to.have.property 'required', on

    it 'sets the errors property if given', ->
      options.errors = ['koo']
      field = new Coreon.Helpers.Field 'foo', 'bar', template, options
      expect(field).to.have.property 'errors'
      expect(field.errors).to.eql ['koo']

    it 'sets the value property if given', ->
      options.value = 'poo'
      field = new Coreon.Helpers.Field 'foo', 'bar', template, options
      expect(field).to.have.property 'value', 'poo'

    it 'set the class property if given', ->
      options.class = 'poo'
      field = new Coreon.Helpers.Field 'foo', 'bar', template, options
      expect(field).to.have.property 'class', 'poo'

    it 'set the type property if given', ->
      options.type = 'poo'
      field = new Coreon.Helpers.Field 'foo', 'bar', template, options
      expect(field).to.have.property 'type', 'poo'


