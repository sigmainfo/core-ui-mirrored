#= require spec_helper
#= require templates/sessions/new_session

describe 'Coreon.Templates[sessions/new_session]', ->

  template = Coreon.Templates['sessions/new_session']

  data = null

  fakeData = ->
    form_for: -> ''
    action_for: -> ''

  beforeEach ->
    data = fakeData()

  render = ->
    $('<div>').html(template data)

  context 'user', ->

    form_for = null

    context 'form', ->

      beforeEach ->
        form_for = sinon.stub data, 'form_for'

      it 'renders form', ->
        form_for
          .withArgs('session', null, noCancel: on)
          .returns '''
            <form class="session new" action="#">
              <input type="submit">
            </form>
          '''
        el = render()
        expect(el).to.have 'form.session.new input[type="submit"]'

    context 'input fields', ->

      input = null

      fakeContext = ->
        input = sinon.stub()
        form: input: input

      beforeEach ->
        context = fakeContext()
        form_for = sinon.stub data, 'form_for', (name, model, opts, block) ->
          block.call context

      it 'renders input for email', ->
        input
          .withArgs('email')
          .returns '<input name="email" type="email" required>'
        el = render()
        expect(el).to.have 'input[name="email"]'

      it 'renders input for password', ->
        input
          .withArgs('password')
          .returns '<input name="password" type="password" required>'
        el = render()
        expect(el).to.have 'input[name="password"]'

  context 'guest', ->

    action_for = null

    beforeEach ->
      action_for = sinon.stub(data, 'action_for')

    it 'renders action', ->
      action_for
        .withArgs('session.create_guest_session')
        .returns '''
          <a class="create-guest-session" href="#">Log in as guest</a>
        '''
      el = render()
      expect(el).to.have 'a.create-guest-session'
