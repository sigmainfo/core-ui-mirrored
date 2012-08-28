#= require spec_helper
#= require views/password_prompt_view

describe "Coreon.Views.PasswordPromptView", ->
  
  beforeEach ->
    @view = new Coreon.Views.PasswordPromptView

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  it "creates container", ->
    @view.$el.should.have.id "coreon-password-prompt"

  describe "#render", ->

    beforeEach ->
      sinon.stub I18n, "t"
    
    afterEach ->
      I18n.t.restore()
    
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
      I18n.t.withArgs("account.login.password").returns "Password:"
      @view.render()
      @view.$el.should.have "label[for='coreon-password-password']"
      @view.$("label[for='coreon-password-password']").should.contain I18n.t "account.login.password"
      @view.$el.should.have "input#coreon-password-password"
      @view.$("input#coreon-password-password").should.have.attr "type", "password"
      @view.$("input#coreon-password-password").should.have.attr "name", "login[password]"
      @view.$("input#coreon-password-password").should.be ":required"

    it "renders logout link", ->
      I18n.t.withArgs("account.logout").returns "Log out"
      @view.render() 
      @view.$el.should.have "a.logout"
      @view.$("a.logout").should.have.attr "href", "/account/logout"
      @view.$("a.logout").should.have.text I18n.t "account.logout"
