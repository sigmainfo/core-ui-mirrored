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
    @stub I18n, "t"
    startLoop = @stub Coreon.Views.Sessions.NewSessionView::, 'startLoop'
    stopLoop = @stub Coreon.Views.Sessions.NewSessionView::, 'stopLoop'
    model = fakeModel()
    view = new Coreon.Views.Sessions.NewSessionView
      model: model
    Coreon.Views.Sessions.NewSessionView::startLoop.reset()
    Coreon.Views.Sessions.NewSessionView::stopLoop.reset()

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

  describe '#remove()', ->

    beforeEach ->
      @spy Backbone.View::, 'remove'

    it 'calls super', ->
      view.remove()
      superImplementation = Backbone.View::remove
      expect(superImplementation).to.have.been.calledOnce

    it 'stops update loop', ->
      view.remove()
      expect(stopLoop).to.have.been.calledOnce
