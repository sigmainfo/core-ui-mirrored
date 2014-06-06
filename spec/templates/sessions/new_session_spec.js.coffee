#= require spec_helper
#= require templates/sessions/new_session

describe 'Coreon.Templates[sessions/new_session]', ->

  template = Coreon.Templates['sessions/new_session']

  data = null

  fakeData = ->
    action_for: -> ''

  beforeEach ->
    data = fakeData()

  render = ->
    $('<div>').html(template data)

  context 'guest login', ->

    action_for = null

    beforeEach ->
      action_for = sinon.stub(data, 'action_for')

    it 'renders action', ->
      action_for
        .withArgs('sessions.login_as_guest')
        .returns '''
          <a class="login-as-guest" href="#">Log in as guest</a>
        '''
      el = render()
      expect(el).to.have 'a.login-as-guest'
