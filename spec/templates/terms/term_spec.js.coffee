#= require spec_helper
#= require templates/terms/term

describe 'Coreon.Templates[terms/term]', ->

  template = Coreon.Templates['terms/term']
  data = null

  render = ->
    $('<div>').html(template data)

  beforeEach ->
    sinon.stub I18n, 't'

    data =
      value: ''
      info: {}
      render: -> ''

  afterEach ->
    I18n.t.restore()

  context 'value', ->

    it 'renders term value', ->
      data.value = 'rose'
      el = render()
      value = el.find('h4')
      expect(value).to.exist
      expect(value).to.have.text 'rose'

  context 'info', ->

    it 'renders info', ->
      data.info = created_at: '2014-04-09'
      helper = sinon.stub()
      data.render = helper
      helper
        .withArgs('shared/info', data: data.info)
        .returns '''
          <table class="system-info">
            <tr>
              <th>created_at</th>
              <td>April 09 2014</td>
            </tr>
          </table>
        '''
      el = render()
      label = el.find('table.system-info th')
      expect(label).to.exist
      expect(label).to.have.text 'created_at'

