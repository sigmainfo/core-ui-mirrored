#= require spec_helper
#= require views/sessions/new_session_view

describe "Coreon.Views.Sessions.NewSessionView", ->

  view = null
  model = null
  startLoop = null
  stopLoop = null

  fakeModel = ->
    new Backbone.Model

  beforeEach ->
    sinon.stub I18n, 't'
    startLoop = sinon.stub Coreon.Views.Sessions.NewSessionView::, 'startLoop'
    stopLoop  = sinon.stub Coreon.Views.Sessions.NewSessionView::, 'stopLoop'
    model = fakeModel()
    view = new Coreon.Views.Sessions.NewSessionView
      model: model
      template: -> ''

  afterEach ->
    I18n.t.restore()
    Coreon.Views.Sessions.NewSessionView::startLoop.restore()
    Coreon.Views.Sessions.NewSessionView::stopLoop.restore()

  it "is a Backbone view", ->
    view.should.be.an.instanceOf Backbone.View

  it "creates container", ->
    view.$el.should.have.id 'coreon-login'

  describe '#initialize()', ->

    it 'starts update loop', ->
      startLoop.reset()
      view.initialize()
      expect(startLoop).to.have.been.calledOnce
      expect(startLoop).to.have.been.calledWith view.updateState

    it 'assigns template', ->
      template = -> ''
      view.initialize template: template
      assigned = view.template
      expect(assigned).to.equal template

    it 'assigns default template when not given', ->
      template = Coreon.Templates['sessions/new_session']
      view.initialize()
      assigned = view.template
      expect(assigned).to.equal template

  describe '#render()', ->

    template = null

    beforeEach ->
      template = sinon.stub(view, 'template').returns ''

    el = (view) ->
      view.$el

    it 'allows chaining', ->
      view.render().should.equal view

    it 'clears markup', ->
      view.$el.html '<div class="old"></div>'
      view.render()
      expect(el view).to.not.have '.old'

    it 'renders template', ->
      view.render()
      expect(template).to.have.been.calledOnce

    it 'inserts markup from template', ->
      template.returns '<div class="new"></div>'

  describe "#updateState()", ->

    beforeEach ->
      view.$el.html '''
        <form action="#">
          <input type="email">
          <input type="password">
          <button type="submit">
        </form>
      '''

    email = (view) ->
      view.$ 'input[type="email"]'

    password = (view) ->
      view.$ 'input[type="password"]'

    submit = (view) ->
      view.$ '*[type="submit"]'

    it "enables submit button when inputs are not empty", ->
      view.$(submit view).prop "disabled", true
      view.$(email view).val "foo@bar.com"
      view.$(password view).val "bar"
      view.updateState()
      view.$(submit view).should.not.be.disabled

    it "disables submit button when login is empty", ->
      view.$(submit view).prop "disabled", false
      view.$(email view).val ""
      view.$(password view).val "bar"
      view.updateState()
      view.$(submit view).should.be.disabled

    it "disables submit button when password is empty", ->
      view.$(submit view).prop "disabled", false
      view.$(email view).val "foo@bar.com"
      view.$(password view).val ""
      view.updateState()
      view.$(submit view).should.be.disabled

  describe "#createSession()", ->

    request = null
    event = null

    beforeEach ->
      view.$el.html '''
        <form action="#">
          <input type="email">
          <input type="password">
          <button type="submit">
        </form>
      '''

    email = (view) ->
      view.$ 'input[type="email"]'

    password = (view) ->
      view.$ 'input[type="password"]'

    submit = (view) ->
      view.$ '*[type="submit"]'

    context 'trigger', ->

      createSession = null

      beforeEach ->
        createSession = sinon.stub view, 'createSession'
        view.delegateEvents()

      it "is triggered on submit", ->
        view.$('form').submit()
        expect(createSession).to.have.been.calledOnce

    context 'authenticate', ->

      authenticate = null

      beforeEach ->
        authenticate = sinon.stub view, 'authenticate'

      email = (view) -> view.$ 'input[type="email"]'

      password = (view) -> view.$ 'input[type="password"]'

      it 'requests session for credentials', ->
        email(view).val 'nobody@blake.com'
        password(view).val 'se7en!'
        view.createSession()
        expect(authenticate).to.have.been.calledOnce
        expect(authenticate).to.have.been.calledWith 'nobody@blake.com'
                                                   , 'se7en!'

  describe '#createGuestSession()', ->

    context 'trigger', ->

      createGuestSession = null

      beforeEach ->
        createGuestSession = sinon.stub view, 'createGuestSession'

      it 'is triggered by click on action', ->
        trigger = $ '<a class="create-guest-session" href="#">Guest</a>'
        view.$el.append trigger
        view.delegateEvents()
        trigger.click()
        expect(createGuestSession).to.have.been.calledOnce

    context 'authenticate', ->

      authenticate = null

      beforeEach ->
        authenticate = sinon.stub view, 'authenticate'

      {GUEST_EMAIL, GUEST_PASSWORD} = Coreon.Views.Sessions.NewSessionView

      it 'authenticates with guest credentials', ->
        view.createGuestSession()
        expect(authenticate).to.have.been.calledOnce
        expect(authenticate).to.have.been.calledWith GUEST_EMAIL
                                                   , GUEST_PASSWORD

  describe '#authenticate()', ->

    authenticate = null
    promise = null

    fakePromise = ->
      done: ->

    fakeSubmit = ->
      submit = $ '<button type="submit">Log in</button>'
      view.$el.append submit
      submit

    fakeInput = (type = 'text', value = '')->
      input = $ "<input type=\"#{type}\">"
      input.val value
      view.$el.append input
      input

    beforeEach ->
      promise = fakePromise()
      authenticate = sinon.stub(Coreon.Models.Session, 'authenticate')
        .returns promise

    afterEach ->
      Coreon.Models.Session.authenticate.restore()

    it 'remotely requests a new session', ->
      view.authenticate 'nobody@blake.com', 'xxx'
      expect(authenticate).to.have.been.calledOnce
      expect(authenticate).to.have.been.calledWith 'nobody@blake.com', 'xxx'

    it 'disables submit button', ->
      submit = fakeSubmit()
      view.authenticate 'nobody@blake.com', 'xxx'
      expect(submit).to.be.disabled

    it 'disables text inputs', ->
      input = fakeInput()
      view.authenticate 'nobody@blake.com', 'xxx'
      expect(input).to.be.disabled

    it 'halts update loop', ->
      view.authenticate 'nobody@blake.com', 'xxx'
      expect(stopLoop).to.have.been.calledOnce

    context 'done', ->

      done = null

      beforeEach ->
        promise.done = (callback) -> done = callback
        view.authenticate 'nobody@blake.com', 'xxx'

      fakeSession = (name = 'Nobody') ->
        new Backbone.Model user: name: name

      resolve = (session) ->
        done session

      context 'with session', ->

        session = null
        info = null

        beforeEach ->
          info = sinon.stub Coreon.Models.Notification, 'info'
          session = fakeSession()

        afterEach ->
          Coreon.Models.Notification.info.restore()

        it 'updates session on model', ->
          resolve session
          expect(model.get 'session').to.equal session

        it 'notifies user', ->
          session.set 'user', name: 'William', silent: yes
          I18n.t
            .withArgs('notifications.account.login', name: 'William')
            .returns 'welcome back, Nobody'
          resolve session
          expect(info).to.have.been.calledOnce
          expect(info).to.have.been.calledWith 'welcome back, Nobody'

      context 'without session', ->

        it 'clears session', ->
          model.set 'session', fakeSession(), silent: yes
          resolve null
          expect(model.get 'session').to.equal null

        it 'reenables submit button', ->
          submit = fakeSubmit()
          resolve null
          expect(submit).to.not.be.disabled

        it 'reenables text inputs', ->
          input = fakeInput()
          resolve null
          expect(input).to.not.be.disabled

        it 'clears password', ->
          input = fakeInput 'password', 'xxx'
          resolve null
          expect(input.val()).to.be.empty

        it 'restarts update loop', ->
          startLoop.reset()
          resolve null
          expect(startLoop).to.have.been.calledOnce
          expect(startLoop).to.have.been.calledWith view.updateState

  describe '#remove()', ->

    beforeEach ->
      sinon.spy Backbone.View::, 'remove'

    afterEach ->
      Backbone.View::remove.restore()

    it 'calls super', ->
      view.remove()
      superImplementation = Backbone.View::remove
      expect(superImplementation).to.have.been.calledOnce

    it 'stops update loop', ->
      view.remove()
      expect(stopLoop).to.have.been.calledOnce
