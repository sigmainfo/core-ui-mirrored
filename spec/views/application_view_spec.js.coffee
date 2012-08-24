#= require spec_helper
#= require views/application_view

describe "Coreon.Views.ApplicationView", ->

  beforeEach ->
    account = new Backbone.Model
    account.notifications = new Backbone.Collection
    account.connections = new Backbone.Collection

    @view = new Coreon.Views.ApplicationView
      el: "#konacha"
      model: account: account

  afterEach ->
    @view.destroy()

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  describe "#initialize", ->

    it "creates login subview", ->
      @view.login.should.be.an.instanceOf Coreon.Views.LoginView
      @view.login.model.should.equal @view.model.account
    
    it "creates footer subview", ->
      @view.footer.should.be.an.instanceOf Coreon.Views.FooterView
      @view.footer.model.should.equal @view.model

    it "creates notifications view", ->
      @view.notifications.should.be.an.instanceOf Coreon.Views.NotificationsView
      @view.notifications.collection.should.equal @view.model.account.notifications

    it "creates widgets subview", ->
      @view.widgets.should.be.an.instanceOf Coreon.Views.WidgetsView
    
  describe "#render", ->

    it "allows chaining", ->
      @view.render().should.equal @view

    it "clears content before rendering", ->
      $("#konacha").append $("<div>", id: "foo")
      @view.render()
      @view.$el.should.not.have "#foo"

    describe "notifications", ->

      it "renders containers", ->
        @view.render()
        @view.$el.should.have "#coreon-top"
        @view.$el.should.have "#coreon-top #coreon-header" 

      it "renders notifications", ->
        @view.render()
        @view.$("#coreon-header").should.have "#coreon-notifications"


    describe "widgets", ->

      it "renders widgets when already logged in", ->
        @view.model.account.set "active", true
        @view.render()
        @view.$el.should.have "#coreon-widgets"
        @view.$("#coreon-widgets").should.have "#coreon-search"

      it "does not append element when not logged in", ->
        @view.model.account.set "active", false
        @view.render()
        @view.$el.should.not.have "#coreon-widgets"


    describe "footer", ->

      it "appends element when already logged in", ->
        @view.model.account.set "active", true
        @view.render()
        @view.$el.should.have "#coreon-footer"

      it "does not append element when not logged in", ->
        @view.model.account.set "active", false
        @view.render()
        @view.$el.should.not.have "#coreon-footer"

    describe "login", ->

      it "renders login form when idle", ->
        @view.model.account.set "active", false
        @view.render()
        @view.$el.should.have "#coreon-login"
        @view.$("#coreon-login").should.have "input[type='submit']"

      it "renders no login form when already logged in", ->
        @view.model.account.set "active", true
        @view.render()
        @view.$el.should.not.have "#coreon-login"

  context "#navigate", ->

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

  context "on login/logout", ->

    context "login", ->

      beforeEach ->
        @view.render()
        @view.model.account.set "active", true, silent: true

      it "renders footer", ->
        sinon.spy @view.footer, "delegateEvents"
        @view.model.account.trigger "activated"
        @view.$el.should.have "#coreon-footer"
        @view.$("#coreon-footer").should.have ".logout"
        @view.footer.delegateEvents.should.have.been.calledOnce

      it "renders widgets", ->
        sinon.spy @view.widgets, "delegateEvents"
        @view.model.account.trigger "activated"
        @view.$el.should.have "#coreon-widgets"
        @view.$("#coreon-widgets").should.have "#coreon-search"
        @view.widgets.delegateEvents.should.have.been.calledOnce

      it "removes login form", ->
        sinon.spy @view.login, "undelegateEvents"
        @view.login.render()
        @view.model.account.trigger "activated"
        @view.$el.should.not.have "#coreon-login"
        @view.login.undelegateEvents.should.have.been.calledOnce

      it "fails gracefully when idle", ->
        @view.model.account.set "active", false, silent: true
        @view.render()
        @view.model.account.trigger "activated"
        @view.$el.should.have "#coreon-login"
        @view.$el.should.not.have "#coreon-footer"
        

    context "logout", ->

      it "renders login form", ->
        sinon.spy @view.login, "delegateEvents"
        @view.model.account.trigger "deactivated"
        @view.$el.should.have "#coreon-login"
        @view.$("#coreon-login").should.have "form.login"
        @view.login.delegateEvents.should.have.been.calledOnce

      it "removes footer", ->
        sinon.spy @view.footer, "undelegateEvents"
        @view.footer.render().$el.appendTo @view.$el
        @view.model.account.trigger "deactivated"
        @view.$el.should.not.have "#coreon-footer"
        @view.footer.undelegateEvents.should.have.been.calledOnce

      it "removes widgets", ->
        sinon.spy @view.widgets, "undelegateEvents"
        @view.widgets.render().$el.appendTo @view.$el
        @view.model.account.trigger "deactivated"
        @view.$el.should.not.have "#coreon-widgets"
        @view.widgets.undelegateEvents.should.have.been.calledOnce

    it "removes bindings on destroy", ->
      sinon.spy @view.model.account, "off"
      @view.destroy()
      @view.model.account.off.should.have.been.calledWith null, null, @view 
