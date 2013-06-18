#= require spec_helper
#= require views/application_view

describe "Coreon.Views.ApplicationView", ->
  
  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.ApplicationView
      model: new Backbone.Model

  afterEach ->
    I18n.t.restore()

  it "is a Backbone View", ->
    @view.should.be.an.instanceof Backbone.View
  
  describe "render()", ->

    it "is triggered when session changes", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.set "session", null
      @view.render.should.have.been.calledOnce

    it "renders containers", ->
      @view.render()
      @view.$el.should.have "#coreon-top"
      @view.$("#coreon-top").should.have "#coreon-header ul#coreon-notifications"
      @view.$("#coreon-top").should.have "#coreon-modal"
      @view.$el.should.have "#coreon-main"
      @view.$("#coreon-main").should.have "#coreon-filters"

    context "with session", ->

      beforeEach ->
        sinon.stub Backbone.history, "start"
        @view.model.set "session", new Backbone.Model(user: name: "nobody"), silent: on

      afterEach ->
        Backbone.history.start.restore()

      it "enables history and triggers route", ->
        @view.render()
        Backbone.history.start.should.have.been.calledOnce
        Backbone.history.start.should.have.been.calledWith  pushState: on

      it "enables history only when idle", ->
        Backbone.History.started = yes
        @view.render()
        Backbone.history.start.should.not.have.been.called

      it "renders widgets", ->
        @view.render()
        @view.$("#coreon-top").should.have "#coreon-widgets"

      it "renders footer", ->
        @view.render()
        @view.$el.should.have "#coreon-footer"
        @view.$("#coreon-footer").should.have ".toggle"
        @view.$("#coreon-footer .toggle").should.have "h3"
        @view.$("#coreon-footer .toggle").should.have "#coreon-progress-indicator"
      
      it "renders account info", ->
        I18n.t.withArgs("account.status", name: "Nobody").returns "Logged in as Nobody"
        @view.model.get("session").set "user", {name: "Nobody"}, silent: yes
        @view.render()
        @view.$("#coreon-footer").should.have "#coreon-account"
        @view.$("#coreon-account p").should.contain "Logged in as Nobody"

      it "hides account info after a short delay", ->
        clock = sinon.useFakeTimers()
        try
          $("#konacha").append @view.$el
          @view.render()
          @view.$("#coreon-account").should.be.visible
          clock.tick 5000
          @view.$("#coreon-account").should.be.hidden
        finally
          clock.restore()

      it "renders logout link", ->
        I18n.t.withArgs("account.logout").returns "Log out"
        @view.render()
        @view.$("#coreon-footer").should.have "a.logout"
        @view.$("a.logout").should.have.attr "href", "/logout"
        @view.$("a.logout").should.have.text "Log out"

    context "without session", ->
      
      beforeEach ->
        sinon.stub Backbone.history, "stop"
        @screen = new Backbone.View
        sinon.stub Coreon.Views.Sessions, "NewSessionView", => @screen
        @view.$el.append '<div id="coreon-main"></div>'

      afterEach ->
        Backbone.history.stop.restore()
        Coreon.Views.Sessions.NewSessionView.restore()

      it "disables history", ->
        @view.render()
        Backbone.history.stop.should.have.been.calledOnce

      it "switches to login screen", ->
        @view.render()
        @view.should.have.property "main", @screen

      it "does not render widgets", ->
        @view.render()
        @view.$el.should.not.have "#coreon-widgets"

      it "does not render footer", ->
        @view.render()
        @view.$el.should.not.have "#coreon-footer"
        
  describe "switch()", ->

    beforeEach ->
      @view.render()

    it "removes previous screen", ->
      previous = remove: sinon.spy()
      @view.main = previous
      @view.switch new Backbone.View
      previous.remove.should.have.been.calledOnce

    it "displays current screen", ->
      current = new Backbone.View
      current.render = sinon.spy()
      @view.switch current
      @view.should.have.property "main", current
      current.render.should.have.been.calledOnce
      $.contains(@view.$("#coreon-main")[0], current.el).should.be.true

    it "clears display when no screen is passed", ->
      @view.switch null
      @view.should.have.property "main", null
      @view.$("#coreon-main").children().should.have.lengthOf 1

  describe "notify()", ->

    beforeEach ->
      sinon.stub Coreon.Views.Notifications, "NotificationView", =>
        @info = new Backbone.View
        @info.render = sinon.stub().returns @info
        @info
      @collection = new Backbone.Collection
      sinon.stub Coreon.Models.Notification, "collection", => @collection
      @view.render()

    afterEach ->
      Coreon.Models.Notification.collection.restore()
      Coreon.Views.Notifications.NotificationView.restore()

    it "is triggered when notification was added", ->
      @view.notify = sinon.spy()
      @view.initialize()
      @collection.trigger "add", message: "I preferred to be called Nobody.", @collection, by: "Nobody"
      @view.notify.should.have.been.calledOnce
      @view.notify.should.have.been.calledWith message: "I preferred to be called Nobody.", @collection, by: "Nobody"

    it "creates notification view", ->
      notification = new Backbone.Model
      @view.notify notification
      Coreon.Views.Notifications.NotificationView.should.have.been.calledOnce
      Coreon.Views.Notifications.NotificationView.should.have.been.calledWithNew
      Coreon.Views.Notifications.NotificationView.should.have.been.calledWith model: notification

    it "appends notification", ->
      $("#konacha").append @view.$el
      @view.notify new Backbone.Model
      @info.render.should.have.been.calledOnce
      $.contains($("#coreon-notifications")[0], @info.el).should.be.true

  describe "toggle()", ->

    beforeEach ->
      $("#konacha").append @view.$el
      @view.$el.append '''
        <div class="toggle">
          <h3>Click to toggle</h3>
        </div>
        <div id="coreon-account">
          <p>Logged in as Nobody</p>
        </div>
      '''
      @event = $.Event "click"
      @event.target = @view.$(".toggle h3")[0]
  
    it "is triggered by click on toggle", ->
      @view.toggle = sinon.spy()
      @view.delegateEvents()
      @view.$(".toggle").trigger @event
      @view.toggle.should.have.been.calledOnce

    it "toggles siblings", ->
      @view.toggle @event
      @view.$("#coreon-account").should.be.hidden
      @view.toggle @event
      @view.$("#coreon-account").should.be.visible
      
