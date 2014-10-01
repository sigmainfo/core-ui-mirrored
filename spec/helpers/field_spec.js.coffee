#= require spec_helper
#= require helpers/field

describe 'Coreon.Helpers.Field', ->

  field_template = null
  options = null

  beforeEach ->
    field_template = 'some_template'
    options = {}

  it 'has a label attribute', ->
    field = new Coreon.Helpers.Field 'foo', 'bar', field_template, {}
    expect(field).to.have.property 'label', 'foo'

  it 'has a name attribute', ->
    field = new Coreon.Helpers.Field 'foo', 'bar', field_template, {}
    expect(field).to.have.property 'name', 'bar'

  it 'generates and id from name if not given', ->
    field = new Coreon.Helpers.Field 'foo', 'bar[cool]', field_template, {}
    expect(field).to.have.property 'id', 'bar_cool_'

  describe 'options', ->

    it 'sets the id given in options as a property', ->
      options.id = 'kaboom'
      field = new Coreon.Helpers.Field 'foo', 'bar[cool]', field_template, options
      expect(field).to.have.property 'id', 'kaboom'

    it 'sets the id given in options as a property', ->
      options.id = 'kaboom'
      field = new Coreon.Helpers.Field 'foo', 'bar', field_template, options
      expect(field).to.have.property 'id', 'kaboom'

    it 'sets the required property to false by default', ->
      field = new Coreon.Helpers.Field 'foo', 'bar', field_template, options
      expect(field).to.have.property 'required', off

    it 'sets the required property to true when given', ->
      options.required = true
      field = new Coreon.Helpers.Field 'foo', 'bar', field_template, options
      expect(field).to.have.property 'required', on

    it 'sets the errors property if given', ->
      options.errors = ['koo']
      field = new Coreon.Helpers.Field 'foo', 'bar', field_template, options
      expect(field).to.have.property 'errors'
      expect(field.errors).to.eql ['koo']

    it 'sets the value property if given', ->
      options.value = 'poo'
      field = new Coreon.Helpers.Field 'foo', 'bar', field_template, options
      expect(field).to.have.property 'value', 'poo'

    it 'set the class property if given', ->
      options.class = 'poo'
      field = new Coreon.Helpers.Field 'foo', 'bar', field_template, options
      expect(field).to.have.property 'class', 'poo'

    it 'set the type property if given', ->
      options.type = 'poo'
      field = new Coreon.Helpers.Field 'foo', 'bar', field_template, options
      expect(field).to.have.property 'type', 'poo'

  describe 'render', ->

    beforeEach ->
      input_partial = sinon.stub Coreon.Helpers, 'render'
      input_partial.returns '<input/>'

    afterEach ->
      Coreon.Helpers.render.restore()

    it 'renders a container', ->
      field = new Coreon.Helpers.Field 'foo', 'bar', field_template, options
      markup = field.render()
      fieldset = $(markup)
      expect(fieldset).to.match 'div'

    it 'renders a label', ->
      field = new Coreon.Helpers.Field 'foo', 'bar', field_template, options
      markup = field.render()
      fieldset = $(markup)
      expect(fieldset).to.contain 'foo'

    it 'renders the given class name', ->
      options.class = 'myclass'
      field = new Coreon.Helpers.Field 'foo', 'bar', field_template, options
      markup = field.render()
      fieldset = $(markup)
      expect(fieldset).to.match 'div.myclass'

    describe 'errors', ->

      it 'renders errors if any', ->
        options.errors = ['an error!']
        field = new Coreon.Helpers.Field 'foo', 'bar', field_template, options
        markup = field.render()
        fieldset = $(markup)
        expect(fieldset).to.have '.error-message'

      it 'doesn\'t render errors if not any', ->
        field = new Coreon.Helpers.Field 'foo', 'bar', field_template, options
        markup = field.render()
        fieldset = $(markup)
        expect(fieldset).to.not.have '.error-message'



