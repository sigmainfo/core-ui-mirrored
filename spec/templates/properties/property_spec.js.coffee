#= require spec_helper
#= require templates/properties/property

describe 'Coreon.Templates[properties/property]', ->

  template = Coreon.Templates['properties/property']
  data = null
  property = null

  render = ->
    $('<div>').html(template data)

  beforeEach ->
    sinon.stub I18n, 't'

    property = new Backbone.Model key: 'gender', value: 'f'
    property.info = -> {}

    data =
      property: property
      render: -> ''

  afterEach ->
    I18n.t.restore()

  it 'renders value', ->
    property.set 'value', 'female', silent: yes
    el = render()
    value = el.find('.value')
    expect(value).to.exist
    expect(value).to.have.text 'female'

  it 'renders info', ->
    info = source: 'Wikipedia'
    property.info = -> info
    helper = sinon.stub()
    data.render = helper
    helper
      .withArgs('shared/info', data: info)
      .returns '''
        <table class="system-info">
          <td>
            <th>source</th>
            <td>Wikipedia</td>
          </td>
        </table>
      '''
    el = render()
    table = el.find('table.system-info')
    expect(table).to.exist
