#= require spec_helper
#= require views/application_view

describe "Coreon.Views.ApplicationView", ->

  beforeEach ->
    Coreon.application = new Backbone.Model
    sinon.stub Coreon.Views.Layout, "ProgressIndicatorView", -> new Backbone.View
    @screen = new Backbone.View
    sinon.stub Coreon.Views.Sessions, "NewSessionView", => @screen
    sinon.stub Coreon.Views.Repositories, "RepositorySelectView", -> new Backbone.View
    sinon.stub Coreon.Views.Widgets, "WidgetsView", =>
      @widgets = new Backbone.View
      @widgets.render = sinon.stub().returns @widgets
      @widgets
    @session = new Backbone.Model
      current_repository_id: "coffeebabe23"
      user: name: "Nobody"
    @session.currentRepository =->

    sinon.stub I18n, "t"
    @view = new Coreon.Views.ApplicationView
      model: Coreon.application

  afterEach ->
    delete Coreon.application
    I18n.t.restore()
    Coreon.Views.Layout.ProgressIndicatorView.restore()
    Coreon.Views.Repositories.RepositorySelectView.restore()
    Coreon.Views.Widgets.WidgetsView.restore()
    Coreon.Views.Sessions.NewSessionView.restore()

  it "is a Backbone View", ->
    @view.should.be.an.instanceof Backbone.View

  it "includes xml form handling", ->
    should.exist @view.xhrFormsOn
    @view.xhrFormsOn.should.equal Coreon.Modules.XhrForms.xhrFormsOn

  describe "initialize()", ->

    it "enables xml form handling", ->
      @view.xhrFormsOn = sinon.spy()
      @view.initialize()
      @view.xhrFormsOn.should.have.been.calledOnce

  describe "render()", ->

    beforeEach ->
      Coreon.application.cacheId = -> "coffee23"

    afterEach ->
      Coreon.application.cacheId = null

    it "is triggered when session changes", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.set "session", null
      @view.render.should.have.been.calledOnce

    it "is triggered when repository changes", ->
      @view.model.set "session", @session, silent: true
      @session.set "current_repository_id", "myrepositoryzuio", silent: true
      @view.render = sinon.spy()
      @view.updateSession()
      @session.set "current_repository_id", "coffeebabe23"
      @view.render.should.have.been.calledOnce

    it "removes subviews", ->
      subview = remove: sinon.spy()
      @view.subviews = [ subview ]
      @view.render()
      subview.remove.should.have.been.calledOnce
      @view.subviews.should.eql []

    it "renders containers", ->
      @view.render()
      @view.$el.should.have "#coreon-top"
      @view.$("#coreon-top").should.have "#coreon-header ul#coreon-notifications"
      @view.$("#coreon-top").should.have "#coreon-modal"
      @view.$el.should.have "#coreon-main"
      @view.$("#coreon-top").should.have "#coreon-filters"

    context "with session", ->

      beforeEach ->
        sinon.stub Backbone.history, "start"
        @view.model.set "session", @session, silent: on
        @session.set "repositories", [], silent: on

      afterEach ->
        Backbone.history.start.restore()

      it "creates widgets", ->
        @view.render()
        Coreon.Views.Widgets.WidgetsView.should.have.been.calledOnce
        Coreon.Views.Widgets.WidgetsView.should.have.been.calledWithNew
        Coreon.Views.Widgets.WidgetsView.should.have.been.calledWith model: @view.model

      it "displays widgets", ->
        @view.render()
        @widgets.render.should.have.been.calledOnce
        $.contains(@view.$("#coreon-top")[0], @widgets.el).should.be.true
        @view.subviews.should.contain @widgets

      it "enables history and triggers route", ->
        @view.render()
        Backbone.history.start.should.have.been.calledOnce
        Backbone.history.start.should.have.been.calledWith  pushState: on

      it "enables history only when idle", ->
        Backbone.History.started = yes
        @view.render()
        Backbone.history.start.should.not.have.been.called

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
        @view.$el.append '<div id="coreon-main"></div>'

      afterEach ->
        Backbone.history.stop.restore()

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
      @view.$("#coreon-main").children().should.have.lengthOf 0

  describe "notify()", ->

    beforeEach ->
      sinon.stub Coreon.Views.Notifications, "NotificationView", =>
        @info = new Backbone.View
        @info.render = sinon.stub().returns @info
        @info.show = sinon.spy()
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

    it "reveals notification", ->
      $("#konacha").append @view.$el
      @view.notify new Backbone.Model
      @info.$el.should.be.hidden
      @info.show.should.have.been.calledOnce

  describe "syncOffset()", ->

    beforeEach ->
      sinon.stub Coreon.Views.Notifications, "NotificationView", =>
        @info = new Backbone.View
        @info.show = ->
        @info

    afterEach ->
      Coreon.Views.Notifications.NotificationView.restore()

    it "is triggered on notification resize", ->
      @view.syncOffset = sinon.spy()
      @view.notify new Backbone.Model
      @info.trigger "resize"
      @view.syncOffset.should.have.been.calledOnce

  describe "clearNotifications()", ->

    beforeEach ->
      @collection = new Backbone.Collection
      sinon.stub Coreon.Models.Notification, "collection", => @collection
      @view.render()

    afterEach ->
      Coreon.Models.Notification.collection.restore()

    it "is triggered when notifications are reset", ->
      @view.clearNotifications = sinon.spy()
      @view.initialize()
      @collection.trigger "reset", []
      @view.clearNotifications.should.have.been.calledOnce

    it "clears notifications", ->
      notification = new Backbone.Model
      @view.initialize()
      @view.notify notification
      @view.$("#coreon-notifications").first().children().length.should.equal 1
      @collection.trigger "reset", []
      @view.$("#coreon-notifications").first().children().length.should.equal 0


  describe "navigate()", ->

    beforeEach ->
      sinon.stub Backbone.history, "navigate"
      @view.$el.append '''
        <a id="inside" href="/path">Click me</a>
        <a id="outside" href="http://url">Click me</a>
      '''
      @event = $.Event "click"
      @event.target = @view.$("a#inside")[0]

    afterEach ->
      Backbone.history.navigate.restore()

    it "is triggered by click on internal link", ->
      @view.navigate = sinon.spy()
      @view.delegateEvents()
      @view.$("a#inside").trigger @event
      @view.navigate.should.have.been.calledOnce
      @view.navigate.should.have.been.calledWith @event

    it "is not triggered by click on external link", ->
      @view.navigate = sinon.spy()
      @view.delegateEvents()
      @event.target = @view.$("a#outside")[0]
      @view.$("a#outside").trigger @event
      @view.navigate.should.not.have.been.called

    it "prevents default", ->
      @event.preventDefault = sinon.spy()
      @view.navigate @event
      @event.preventDefault.should.have.been.calledOnce

    it "calls navigate on history", ->
      $(@event.target).attr "href", "/logout"
      @view.navigate @event
      Backbone.history.navigate.should.have.been.calledOnce
      Backbone.history.navigate.should.have.been.calledWith "logout", trigger: yes

    it "can have nested elements", ->
      @view.$el.append '<a id="nested" href="/foo"><p>Inner</p></a>'
      @event.target = @view.$("#nested p")[0]
      @view.navigate @event
      Backbone.history.navigate.should.have.been.calledOnce
      Backbone.history.navigate.should.have.been.calledWith "foo", trigger: yes

  describe "reauthenticate()", ->

    beforeEach ->
      Coreon.application.cacheId = -> "coffee23"
      sinon.stub Coreon.Views.Account, "PasswordPromptView", =>
        @prompt = new Backbone.View
      @session = new Backbone.Model
        auth_token: "supersecrettoken"
        user:
          name: "Nobody"
      @session.currentRepository = ->
      @view.model.set "session", @session

    afterEach ->
      Coreon.application.cacheId = null
      Coreon.Views.Account.PasswordPromptView.restore()

    it "is triggered by changes on session token", ->
      @view.reauthenticate = sinon.spy()
      @view.updateSession()
      @session.set "auth_token", "someothersecrettoken"
      @view.reauthenticate.callCount.should.equal 1
      @view.reauthenticate.firstCall.args[0].should.equal @session
      @view.reauthenticate.firstCall.args[1].should.equal "someothersecrettoken"

    it "can prompt", ->
      should.exist Coreon.Modules.Prompt
      @view.prompt.should.equal Coreon.Modules.Prompt.prompt

    it "displays password prompt when token is not set", ->
      @view.prompt = sinon.spy()
      @view.reauthenticate @session, null
      Coreon.Views.Account.PasswordPromptView.callCount.should.equal 1
      Coreon.Views.Account.PasswordPromptView.should.have.been.calledWithNew
      Coreon.Views.Account.PasswordPromptView.firstCall.args[0].should.eql model: @session
      @view.prompt.callCount.should.equal 1
      @view.prompt.firstCall.args[0].should.equal @prompt

    it "hides password prompt when token is set", ->
      @view.prompt = sinon.spy()
      @view.reauthenticate @session, "newcoolsessiontoken"
      Coreon.Views.Account.PasswordPromptView.should.not.have.been.called
      @view.prompt.should.have.been.calledOnce
      @view.prompt.should.have.been.calledWith null

  describe "repository()", ->

    beforeEach ->
      @session = new Backbone.Model
      @session.currentRepository = -> null
      @view.model.set "session", @session, silent: yes

    it "returns current repository when no id is given", ->
      repository = new Backbone.Model
      @session.currentRepository = -> repository
      @view.repository().should.equal repository

    it "doesn't switch to default repository when no id is given", ->
      repository = new Backbone.Model
      @session.currentRepository = -> repository
      @session.set = sinon.spy()
      @view.repository().should.equal repository
      @session.set.should.not.have.been.called

    it "returns null without a session", ->
      @view.model.set "session", null, silent: yes
      should.equal @view.repository(), null

    it "selects current repository when id is passed", ->
      @view.repository "myrepositoryzuio"
      @view.model.get("session").get("current_repository_id").should.equal "myrepositoryzuio"

  describe "query()", ->

    beforeEach ->
      @view.$el.append '''
        <input id="coreon-search-query" type="text" name="q" value=""/>
        <div id="coreon-search-target-select">
          <p class="hint">I am a hint</p>
        </div>
      '''
      @input = @view.$("#coreon-search-query")
      @hint = @view.$("#coreon-search-target-select .hint")

    it "returns value from search input", ->
      @input.val "whappan?"
      @view.query().should.equal "whappan?"

    it "sets value on search input", ->
      @view.query "poet"
      @input.should.have.value "poet"

    it "hides hint when query is not empty", ->
      $("#konacha").append @view.$el
      @view.query "poet"
      @hint.should.be.hidden

    it "shows hint when query is empty", ->
      $("#konacha").append @view.$el
      @hint.hide()
      @view.query ""
      @hint.should.be.visible

  describe "toggle()", ->

    beforeEach ->
      $("#konacha").append @view.$el
      @view.$el.append '''
        <div id="coreon-footer">
          <div class="toggle">
            <h3>Click to toggle</h3>
          </div>
          <div id="coreon-account">
            <p>Logged in as Nobody</p>
          </div>
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
