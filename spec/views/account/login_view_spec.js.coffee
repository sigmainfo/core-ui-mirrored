#= require spec_helper
#= require views/account/login_view

describe "Coreon.Views.Account.LoginView", ->
  
  beforeEach ->
    @view = new Coreon.Views.Account.LoginView 

  it "is a simple view view", ->
    @view.should.be.an.instanceOf Coreon.Views.SimpleView

  it "creates container", ->
    @view.$el.should.have.id "coreon-login"

  describe "#render", ->

    it "allows chaining", ->
      @view.render().should.equal @view
    
    it "renders form", ->
      @view.render()
      @view.$el.should.have "form.login"
      @view.$("form").should.have "input[type='submit']"
      @view.$("input[type='submit']").should.have.attr "name", "login"
      @view.$("input[type='submit']").should.have.attr "value", I18n.t "account.login.submit"
      @view.$("input[type='submit']").should.be.disabled

    it "renders input for email", ->
      @view.render()
      @view.$el.should.have "label[for='coreon-login-email']"
      @view.$("label[for='coreon-login-email']").should.contain I18n.t "account.login.email"
      @view.$el.should.have "input[id='coreon-login-email']"
      @view.$("input[id='coreon-login-email']").should.have.attr "type", "text"
      @view.$("input[id='coreon-login-email']").should.have.attr "name", "login[email]"
      @view.$("input[id='coreon-login-email']").should.have.attr "required"

    it "renders input for password", ->
      @view.render()
      @view.$el.should.have "label[for='coreon-login-password']"
      @view.$("label[for='coreon-login-password']").should.contain I18n.t "account.login.password"
      @view.$el.should.have "input[id='coreon-login-password']"
      @view.$("input[id='coreon-login-password']").should.have.attr "type", "password"
      @view.$("input[id='coreon-login-password']").should.have.attr "name", "login[password]"
      @view.$("input[id='coreon-login-password']").should.have.attr "required"

  describe "on keyup", ->

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

  describe "on submit", ->
    
    beforeEach ->
      @event = new jQuery.Event "submit"
      @view.model = activate: ->
      @view.render().$el.appendTo "#konacha"

    it "handles submit events exclusively", ->
      sinon.spy @event, "preventDefault"
      sinon.spy @event, "stopPropagation"
      @view.$("form").trigger @event
      @event.preventDefault.should.have.been.calledOnce
      @event.stopPropagation.should.have.been.calledOnce

    it "authenticates account", ->
      @view.model.activate = sinon.spy()
      @view.$("#coreon-login-email").val "nobody@blake.com"
      @view.$("#coreon-login-password").val "se7en"
      @view.$("form").trigger @event
      @view.model.activate.should.have.been.calledWith "nobody@blake.com", "se7en"

      
