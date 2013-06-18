#= require spec_helper
#= require views/sessions/new_session_view

describe "Coreon.Views.Sessions.NewSessionView", ->
  
  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Sessions.NewSessionView
      model: new Backbone.Model

  afterEach ->
    I18n.t.restore()

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  it "creates container", ->
    @view.$el.should.have.id "coreon-login"

  describe "render()", ->

    it "allows chaining", ->
      @view.render().should.equal @view
    
    it "renders form", ->
      I18n.t.withArgs("account.login.submit").returns "Log in"
      @view.render()
      @view.$el.should.have "form.login"
      @view.$("form").should.have "input[type='submit']"
      @view.$("input[type='submit']").should.have.attr "name", "login"
      @view.$("input[type='submit']").should.have.attr "value", "Log in"
      @view.$("input[type='submit']").should.be.disabled

    it "renders input for email", ->
      I18n.t.withArgs("account.login.email").returns "Email"
      @view.render()
      @view.$el.should.have "label[for='coreon-login-email']"
      @view.$("label[for='coreon-login-email']").should.contain "Email"
      @view.$el.should.have "input[id='coreon-login-email']"
      @view.$("input[id='coreon-login-email']").should.have.attr "type", "text"
      @view.$("input[id='coreon-login-email']").should.have.attr "name", "login[email]"
      @view.$("input[id='coreon-login-email']").should.have.attr "required"

    it "renders input for password", ->
      I18n.t.withArgs("account.login.password").returns "Password"
      @view.render()
      @view.$el.should.have "label[for='coreon-login-password']"
      @view.$("label[for='coreon-login-password']").should.contain "Password"
      @view.$el.should.have "input[id='coreon-login-password']"
      @view.$("input[id='coreon-login-password']").should.have.attr "type", "password"
      @view.$("input[id='coreon-login-password']").should.have.attr "name", "login[password]"
      @view.$("input[id='coreon-login-password']").should.have.attr "required"

  describe "updateState()", ->

    beforeEach ->
      @view.render()

    it "enables submit button when inputs are not empty", ->
      @view.$("input[type='submit']").prop "disabled", true
      @view.$("#coreon-login-email").val "foo@bar.com"
      @view.$("#coreon-login-password").val "bar"
      @view.$("#coreon-login-password").keyup()
      @view.$("input[type='submit']").should.not.be.disabled
      
    it "disables submit button when login is empty", ->
      @view.$("input[type='submit']").prop "disabled", false
      @view.$("#coreon-login-email").val ""
      @view.$("#coreon-login-password").val "bar"
      @view.$("#coreon-login-password").keyup()
      @view.$("input[type='submit']").should.be.disabled

    it "disables submit button when password is empty", ->
      @view.$("input[type='submit']").prop "disabled", false
      @view.$("#coreon-login-email").val "foo@bar.com"
      @view.$("#coreon-login-password").val ""
      @view.$("#coreon-login-password").keyup()
      @view.$("input[type='submit']").should.be.disabled

    it "updates state on paste", ->
      @view.$("input[type='submit']").prop "disabled", true
      @view.$("#coreon-login-email").val "foo@bar.com"
      @view.$("#coreon-login-password").val "bar"
      @view.$("#coreon-login-password").trigger "paste"
      @view.$("input[type='submit']").should.not.be.disabled

  describe "create()", ->
    
    beforeEach ->
      sinon.stub Coreon.Models.Session, "authenticate", => @request = $.Deferred()
      @event = $.Event "submit"
      @view.render()

    afterEach ->
      Coreon.Models.Session.authenticate.restore()
      
    it "is triggered on submit", ->
      @view.create = sinon.spy()
      @view.delegateEvents()
      @view.$("form").trigger @event
      @view.create.should.have.been.calledOnce
      @view.create.should.have.been.calledWith @event
      
    it "prevents default", ->
      @event.preventDefault = sinon.spy()
      @view.create @event
      @event.preventDefault.should.have.been.calledOnce

    it "disables button to prevent second click", ->
      @view.$(":disabled").prop "disabled", no
      @view.create @event
      @view.$('[type="submit"]').should.be.disabled

    context "session request", ->
      
      beforeEach ->
        @view.$("#coreon-login-email").val "nobody@login.me"
        @view.$("#coreon-login-password").val "xxx"
        @session = new Backbone.Model user: name: "William Blake"

      it "creates session from form", ->
        @view.create @event
        Coreon.Models.Session.authenticate.should.have.been.calledOnce
        Coreon.Models.Session.authenticate.should.have.been.calledWith "nobody@login.me", "xxx"

      context "no session", ->
        
        it "clears password field on failure", ->
          @view.create @event
          @request.resolve null
          @view.$("#coreon-login-password").should.have.value ""

        it "reenable form", ->
          @view.create @event
          @request.resolve null
          @view.$(":disabled").should.have.lengthOf 0

      context "with session", ->

        beforeEach ->
          sinon.stub Coreon.Models.Notification, "info"

        afterEach ->
          Coreon.Models.Notification.info.restore()

        it "updates session on application", ->
          session = token: "you-are-in-123"
          @view.create @event
          @request.resolve @session
          @view.model.get("session").should.equal @session

        it "creates notification message", ->
          I18n.t.withArgs("notifications.account.login", name: "William Blake").returns "Successfully logged in as William Blake." 
          @session.set "user", name: "William Blake", silent: yes
          @view.create @event
          @request.resolve @session
          Coreon.Models.Notification.info.should.have.been.calledOnce
          Coreon.Models.Notification.info.should.have.been.calledWith "Successfully logged in as William Blake."

          
        
        
           
