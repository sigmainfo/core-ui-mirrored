#= require spec_helper
#= require views/account/password_prompt_view

describe "Coreon.Views.Account.PasswordPromptView", ->

  beforeEach ->
    @view = new Coreon.Views.Account.PasswordPromptView model: new Backbone.Model

  it "is a simple view", ->
    @view.should.be.an.instanceof Coreon.Views.SimpleView

  it "creates container", ->
    @view.$el.should.have.id "coreon-password-prompt"

  describe "render()", ->

    it "can be chained", ->
      @view.render().should.equal @view

    it "renders prompt", ->
     @view.render()
     @view.$el.should.have ".prompt"

    it "renders message", ->
      I18n.t.withArgs("account.password_prompt.message").returns "Please enter password:"
      @view.render()
      @view.$el.should.contain "Please enter password:"

    it "renders form", ->
      I18n.t.withArgs("account.password_prompt.submit").returns "Proceed"
      @view.render()
      @view.$el.should.have "form.password"
      @view.$el.should.have "form.password input[type='submit']"
      @view.$("input[type='submit']").should.have.attr "name", "login"
      @view.$("input[type='submit']").should.have.attr "value", "Proceed"

    it "renders input for password", ->
      I18n.t.withArgs("session.password").returns "Password:"
      @view.render()
      @view.$el.should.have "label[for='coreon-password-password']"
      @view.$("label[for='coreon-password-password']").should.contain 'Password:'
      @view.$el.should.have "input#coreon-password-password"
      @view.$("input#coreon-password-password").should.have.attr "type", "password"
      @view.$("input#coreon-password-password").should.have.attr "name", "login[password]"
      @view.$("input#coreon-password-password").should.have.attr "required"

    it "renders logout link", ->
      I18n.t.withArgs("account.logout").returns "Log out"
      @view.render()
      @view.$el.should.have "a.logout"
      @view.$("a.logout").should.have.attr "href", "/logout"
      @view.$("a.logout").should.have.text I18n.t "account.logout"

  describe "on submit", ->

    beforeEach ->
      @event = $.Event "submit"
      @view.model = new Backbone.Model
      @view.model.reauthenticate = @spy()
      @view.render().$el.appendTo "#konacha"

    it "handles submit events exclusively", ->
      @spy @event, "preventDefault"
      @spy @event, "stopPropagation"
      @view.$("form").trigger @event
      @event.preventDefault.should.have.been.calledOnce
      @event.stopPropagation.should.have.been.calledOnce

    it "authenticates account", ->
      @view.model.set "login", "nobody"
      @view.$("#coreon-password-password").val "se7en"
      @view.$("form").trigger @event
      @view.model.reauthenticate.should.have.been.calledWith "se7en"
