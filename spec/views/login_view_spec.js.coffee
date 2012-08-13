#= require spec_helper
#= require views/login_view

describe "Coreon.Views.LoginView", ->
  
  beforeEach ->
    @view = new Coreon.Views.LoginView 

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

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

    it "renders input for login", ->
      @view.render()
      @view.$el.should.have "label[for='coreon-login-login']"
      @view.$("label[for='coreon-login-login']").should.contain I18n.t "account.login.login"
      @view.$el.should.have "input[id='coreon-login-login']"
      @view.$("input[id='coreon-login-login']").should.have.attr "type", "text"
      @view.$("input[id='coreon-login-login']").should.have.attr "name", "login[login]"

    it "renders input for password", ->
      @view.render()
      @view.$el.should.have "label[for='coreon-login-password']"
      @view.$("label[for='coreon-login-password']").should.contain I18n.t "account.login.password"
      @view.$el.should.have "input[id='coreon-login-password']"
      @view.$("input[id='coreon-login-password']").should.have.attr "type", "password"
      @view.$("input[id='coreon-login-password']").should.have.attr "name", "login[password]"

  describe "on submit", ->
    
    beforeEach ->
      @event = new jQuery.Event "submit"
      @view.model = login: -> true
      @view.render().$el.appendTo "#konacha"

    it "handles submit events exclusively", ->
      sinon.spy @event, "preventDefault"
      sinon.spy @event, "stopPropagation"
      @view.$("form").trigger @event
      @event.preventDefault.should.have.been.calledOnce
      @event.stopPropagation.should.have.been.calledOnce

    it "authenticates account", ->
      sinon.spy @view.model, "login"
      @view.$("#coreon-login-login").val "nobody"
      @view.$("#coreon-login-password").val "se7en"
      @view.$("form").trigger @event
      @view.model.login.should.have.been.calledWith "nobody", "se7en"

      
