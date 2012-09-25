#= require spec_helper
#= require views/application_view
#= require views/simple_view

describe "Coreon.Views.ApplicationView", ->

  beforeEach ->
    @view = new Coreon.Views.ApplicationView
      el: "#konacha"
      model: _(new Backbone.Model).extend
        notifications: new Backbone.Collection
        connections: new Backbone.Collection

  afterEach ->
    @view.destroy()

  it "is a composite view", ->
    @view.should.be.an.instanceOf Coreon.Views.CompositeView

  describe "#initialize", ->

    it "creates header", ->
      @view.header.should.be.an.instanceOf Coreon.Views.Layout.HeaderView
      @view.header.collection.should.equal @view.model.notifications
      @view.subviews.should.contain @view.header
    
  describe "#render", ->

    it "allows chaining", ->
      @view.render().should.equal @view

    it "clears content before rendering", ->
      $("#konacha").append $("<div>", id: "foo")
      @view.render()
      @view.$el.should.not.have "#foo"

    it "renders containers", ->
      @view.render()
      @view.$el.should.have "#coreon-top"
      @view.$("#coreon-top").should.have "#coreon-modal"
      @view.$el.should.have "#coreon-main"

    it "renders header", ->
      @view.render()
      @view.$("#coreon-top").should.have "#coreon-header"
      @view.$("#coreon-header").should.have "#coreon-notifications"

    context "when active", ->

      beforeEach ->
        @view.model.set "active", true

      it "renders application", ->
        @view.render()
        @view.$("#coreon-top").should.have "#coreon-widgets"
        @view.$("#coreon-widgets").should.have "#coreon-search"
        @view.$el.should.have "#coreon-footer"
        @view.$("#coreon-footer").should.have "#coreon-account"

      it "does not render login", ->
        @view.render()
        @view.$el.should.not.have "#coreon-login"

    context "when inactive", ->
      
      beforeEach ->
        @view.model.set "active", false

      it "renders login", ->
        @view.render()
        @view.$el.should.have "#coreon-login"
      
      it "does not render application", ->
        @view.render() 
        @view.$el.should.not.have "#coreon-widgets"
        @view.$el.should.not.have "#coreon-footer"

  describe "#activate", ->

    beforeEach ->
      @view.render()
      @view.model.set "active", true, silent: true

    it "is triggered by model", ->
      @view.activate = sinon.spy()
      @view.initialize()
      @view.model.trigger "activated"
      @view.activate.should.have.been.calledOnce

    it "clears view", ->
      subview = new Coreon.Views.SimpleView
      @view.append subview
      @view.activate()
      @view.subviews.should.not.contain subview

    it "renders widgets", ->
      @view.activate()
      @view.widgets.should.be.an.instanceOf Coreon.Views.Widgets.WidgetsView
      @view.$("#coreon-top").should.have "#coreon-widgets"
      @view.$("#coreon-widgets").should.have "#coreon-search"

    it "renders footer", ->
      @view.activate()
      @view.footer.should.be.an.instanceOf Coreon.Views.Layout.FooterView
      @view.footer.model.should.equal @view.model
      @view.$el.should.have "#coreon-footer"
      @view.$("#coreon-footer").should.have "#coreon-account"

    it "fails when not active", ->
      @view.model.set "active", false, silent: true
      @view.activate()
      @view.$el.should.not.have "#coreon-widgets"

  describe "#deactivate", ->
  
    beforeEach ->
      @view.render()
      @view.model.set "active", false, silent: true

    it "is triggered by model", ->
      @view.deactivate = sinon.spy()
      @view.initialize()
      @view.model.trigger "deactivated"
      @view.deactivate.should.have.been.calledOnce
      
    it "clears view", ->
      subview = new Coreon.Views.SimpleView
      @view.append subview
      @view.deactivate()
      @view.subviews.should.not.contain subview

    it "renders login", ->
      @view.deactivate()
      @view.login.should.be.an.instanceOf Coreon.Views.Account.LoginView
      @view.login.model.should.equal @view.model
      @view.$("#coreon-main").should.have "#coreon-login"
      @view.$("#coreon-login").should.have "form.login input[type='submit']"

  describe "#reauthorize", ->

    beforeEach ->
      @view.render()

    it "is triggered by account", ->
      @view.reauthorize = sinon.spy()
      @view.initialize()
      @view.model.trigger "unauthorized"
      @view.reauthorize.should.have.been.calledOnce

    it "renders password prompt", ->
      @view.reauthorize()
      @view.prompt.should.be.an.instanceOf Coreon.Views.Account.PasswordPromptView
      @view.prompt.model.should.equal @view.model
      @view.$("#coreon-modal").should.have "#coreon-password-prompt"

  describe "#reactivate", ->

    beforeEach ->
      @view.reauthorize()

    it "is triggered by account", ->
      @view.reactivate = sinon.spy()
      @view.initialize()
      @view.model.trigger "reactivated"
      @view.reactivate.should.have.been.calledOnce

    it "removes password prompt", ->
      @view.reactivate()
      @view.$el.should.not.have "#coreon-password-prompt"

    it "resumes all dropped connections", ->
      conn1 = new Backbone.Model xhr: status: 200
      conn2 = new Backbone.Model xhr: status: 403
      conn3 = new Backbone.Model xhr: status: 0
      conn1.resume = sinon.spy()
      conn2.resume = sinon.spy()
      conn3.resume = sinon.spy()
      @view.model.connections.add [ conn1, conn2, conn3 ]
      @view.reactivate()
      conn2.resume.should.have.been.calledOnce
      conn1.resume.should.not.have.been.called
      conn3.resume.should.not.have.been.called
  describe "#navigate", ->

    beforeEach ->
      Backbone.history = new Backbone.History
      sinon.spy Backbone.history, "navigate"
      @link = $("<a>", href: "/foo/bar/baz").html "Foo Bar Baz"
      @view.$el.append @link
      @event = new jQuery.Event "click"
      sinon.spy @event, "preventDefault"

    it "delegates navigation to history when clicking a relative link", ->
      @link.attr "href", "/this/is/within/the/app"
      @link.trigger @event
      Backbone.history.navigate.should.have.been.calledWith "/this/is/within/the/app", trigger: true
      @event.preventDefault.should.have.been.called

    it "triggers default action for other links", ->
      @link.attr "href", "http://go/somewhere/else"
      @link.trigger @event
      Backbone.history.navigate.should.not.have.been.called
      @event.preventDefault.should.not.have.been.called

  describe "#switch", ->

    beforeEach ->
      @view.render()
      @screen1 = new Coreon.Views.SimpleView
      @view.switch @screen1
      @screen2 = new Coreon.Views.SimpleView id: "screen2"

    it "destroys current screen", ->
      @screen1.destroy = sinon.spy()
      @view.switch @screen2
      @screen1.destroy.should.have.been.calledOnce
 
    it "appends screen", ->
      @view.switch @screen2
      @view.$("#coreon-main").should.have "#screen2"

    it "renders screen", ->
      @screen2.render = sinon.stub().returns @screen2
      @view.switch @screen2
      @screen2.render.should.have.been.calledOnce
    
  describe "#destroy", ->
    
    it "removes bindings on destroy", ->
      sinon.spy @view.model, "off"
      @view.destroy()
      @view.model.off.should.have.been.calledWith null, null, @view 

        
