#= require spec_helper
#= require views/sessions/new_session_view

describe "Coreon.Views.Sessions.NewSessionView", ->

  view = null

  beforeEach ->
    sinon.stub I18n, "t"
    sinon.stub Coreon.Views.Sessions.NewSessionView::, 'startLoop'
    sinon.stub Coreon.Views.Sessions.NewSessionView::, 'stopLoop'
    view = new Coreon.Views.Sessions.NewSessionView
      model: new Backbone.Model
      template: -> ''
    Coreon.Views.Sessions.NewSessionView::startLoop.reset()
    Coreon.Views.Sessions.NewSessionView::stopLoop.reset()

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
      view.initialize()
      startLoop = view.startLoop
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

  describe "#create()", ->

    request = null
    event = null

    beforeEach ->
      sinon.stub Coreon.Models.Session, 'authenticate', => request = $.Deferred()
      event = $.Event 'submit'
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

    afterEach ->
      Coreon.Models.Session.authenticate.restore()

    it "is triggered on submit", ->
      view.create = sinon.spy()
      view.delegateEvents()
      view.$('form').trigger event
      view.create.should.have.been.calledOnce
      view.create.should.have.been.calledWith event

    it "prevents default", ->
      event.preventDefault = sinon.spy()
      view.create event
      event.preventDefault.should.have.been.calledOnce

    it "disables button to prevent second click", ->
      view.$(":disabled").prop "disabled", no
      view.create event
      view.$(submit view).should.be.disabled

    it 'stops update loop', ->
      view.create event
      stopLoop = view.stopLoop
      expect(stopLoop).to.have.been.calledOnce

    context "session request", ->

      session = null

      beforeEach ->
        view.$(email view).val "nobody@login.me"
        view.$(password view).val "xxx"
        session = new Backbone.Model user: name: "William Blake"

      it "creates session from form", ->
        view.create event
        Coreon.Models.Session.authenticate.should.have.been.calledOnce
        Coreon.Models.Session.authenticate.should.have.been.calledWith "nobody@login.me", "xxx"

      context "no session", ->

        it "clears password field on failure", ->
          view.create event
          request.resolve null
          view.$(password view).should.have.value ""

        it "reenable form", ->
          view.create event
          request.resolve null
          view.$(":disabled").should.have.lengthOf 0

        it 'restarts update loop', ->
          view.create event
          request.resolve null
          startLoop = view.startLoop
          expect(startLoop).to.have.been.calledOnce
          expect(startLoop).to.have.been.calledWith view.updateState

      context "with session", ->

        beforeEach ->
          sinon.stub Coreon.Models.Notification, "info"

        afterEach ->
          Coreon.Models.Notification.info.restore()

        it "updates session on application", ->
          session.set 'token', 'you-are-in-123', silent: yes
          view.create event
          request.resolve session
          view.model.get("session").should.equal session

        it "creates notification message", ->
          I18n.t
            .withArgs('notifications.account.login', name: 'William Blake')
            .returns 'Successfully logged in as William Blake.'
          session.set 'user', name: 'William Blake', silent: yes
          view.create event
          request.resolve session
          Coreon.Models.Notification.info.should.have.been.calledOnce
          Coreon.Models.Notification.info.should.have.been.calledWith "Successfully logged in as William Blake."

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
      stopLoop = view.stopLoop
      view.remove()
      expect(stopLoop).to.have.been.calledOnce
