#= require spec_helper
#= require views/application_view

describe "Coreon.Views.ApplicationView", ->

  view = null
  app = null
  login = null

  beforeEach ->
    app = Coreon.application = new Backbone.Model
    @stub Coreon.Views.Layout, "ProgressIndicatorView", -> new Backbone.View
    @stub Coreon.Views.Sessions, "NewSessionView", -> login = new Backbone.View
    @stub Coreon.Views.Repositories, "RepositorySelectView", -> new Backbone.View
    @stub Coreon.Views.Widgets, "WidgetsView", =>
      @widgets = new Backbone.View
      @widgets.render = @stub().returns @widgets
      @widgets
    @session = new Backbone.Model
      current_repository_id: "coffeebabe23"
      user: name: "Nobody"
    @session.currentRepository =->

    panels =
      removeAll: ->
      createAll: ->
      update: ->
    @stub Coreon.Lib.Panels.PanelsManager, 'create'
    Coreon.Lib.Panels.PanelsManager.create.returns panels

    view = new Coreon.Views.ApplicationView
      model: Coreon.application

  afterEach ->
    delete Coreon.application

  it "is a Backbone View", ->
    view.should.be.an.instanceof Backbone.View

  it "includes xml form handling", ->
    should.exist view.xhrFormsOn
    view.xhrFormsOn.should.equal Coreon.Modules.XhrForms.xhrFormsOn

  describe "initialize()", ->

    it "enables xml form handling", ->
      view.xhrFormsOn = @spy()
      view.initialize()
      view.xhrFormsOn.should.have.been.calledOnce

    it 'assigns panels manager', ->
      panels =
        removeAll: ->
        createAll: ->
        update: ->
      create = Coreon.Lib.Panels.PanelsManager.create
      create.withArgs(view).returns panels
      view.initialize()
      manager = view.panels
      expect(manager).to.equal panels

  describe "render()", ->

    beforeEach ->
      Coreon.application.cacheId = -> "coffee23"

    afterEach ->
      Coreon.application.cacheId = null

    it "is triggered when session changes", ->
      view.render = @spy()
      view.initialize()
      view.model.set "session", null
      view.render.should.have.been.calledOnce

    it "is triggered when repository changes", ->
      view.model.set "session", @session, silent: true
      @session.set "current_repository_id", "myrepositoryzuio", silent: true
      view.render = @spy()
      view.updateSession()
      @session.set "current_repository_id", "coffeebabe23"
      view.render.should.have.been.calledOnce

    it "removes subviews", ->
      subview = remove: @spy()
      view.subviews = [ subview ]
      view.render()
      subview.remove.should.have.been.calledOnce
      view.subviews.should.not.include subview

    it 'removes panels', ->
      remove = @spy()
      panels = view.panels
      panels.removeAll = remove
      view.render()
      expect(remove).to.have.been.calledOnce

    it "renders containers", ->
      view.render()
      view.$el.should.have "#coreon-top"
      view.$("#coreon-top").should.have "#coreon-header ul#coreon-notifications"
      view.$("#coreon-top").should.have "#coreon-modal"
      view.$el.should.have "#coreon-main"
      view.$("#coreon-top").should.have "#coreon-filters"

    context "with session", ->

      beforeEach ->
        @stub Backbone.history, "start"
        view.model.set "session", @session, silent: on
        @session.set "repositories", [], silent: on

      it "creates widgets", ->
        view.render()
        Coreon.Views.Widgets.WidgetsView.should.have.been.calledOnce
        Coreon.Views.Widgets.WidgetsView.should.have.been.calledWithNew
        Coreon.Views.Widgets.WidgetsView.should.have.been.calledWith model: view.model

      it "displays widgets", ->
        view.render()
        @widgets.render.should.have.been.calledOnce
        $.contains(view.$("#coreon-top")[0], @widgets.el).should.be.true
        view.subviews.should.contain @widgets

      it 'creates panels', ->
        panels = view.panels
        create = @spy()
        panels.createAll = create
        update = @spy()
        panels.update = update
        view.render()
        expect(create).to.have.been.calledOnce
        expect(update).to.have.been.calledOnce

      it "enables history and triggers route", ->
        view.render()
        Backbone.history.start.should.have.been.calledOnce
        Backbone.history.start.should.have.been.calledWith  pushState: on

      it "enables history only when idle", ->
        Backbone.History.started = yes
        view.render()
        Backbone.history.start.should.not.have.been.called

      context 'footer', ->

        it "renders footer", ->
          view.render()
          view.$el.should.have "#coreon-footer"
          view.$("#coreon-footer").should.have ".toggle"
          view.$("#coreon-footer .toggle").should.have "h3"
          view.$("#coreon-footer .toggle").should.have "#coreon-progress-indicator"

        it "renders account info", ->
          I18n.t.withArgs("account.status", name: "Nobody").returns "Logged in as Nobody"
          view.model.get("session").set "user", {name: "Nobody"}, silent: yes
          view.render()
          view.$("#coreon-footer").should.have "#coreon-account"
          view.$("#coreon-account p").should.contain "Logged in as Nobody"

        it "hides account info after a short delay", ->
          $("#konacha").append view.$el
          view.render()
          view.$("#coreon-account").should.be.visible
          @clock.tick 5000
          view.$("#coreon-account").should.be.hidden

        it "renders logout link", ->
          I18n.t.withArgs("account.logout").returns "Log out"
          view.render()
          view.$("#coreon-footer").should.have "a.logout"
          view.$("a.logout").should.have.attr "href", "/logout"
          view.$("a.logout").should.have.text "Log out"

        it 'renders theme switcher', ->
          I18n.t.withArgs('themes.caption').returns 'Theme'
          view.render()
          caption = view.$('#coreon-footer .themes span')
          expect(caption).to.exist
          expect(caption).to.have.text 'Theme'

        it 'renders switches for themes', ->
          view.render()
          link = view.$('#coreon-footer .themes a[data-name]')
          expect(link).to.have.lengthOf 2
          expect(link).to.have.attr 'href', 'javascript:void(0)'

        it 'renders switch for default theme', ->
          I18n.t.withArgs('themes.names.berlin').returns 'Default'
          view.render()
          link = view.$('#coreon-footer .themes a[data-name]').eq(0)
          expect(link).to.have.data 'name', 'berlin'
          expect(link).to.have.text 'Default'
          expect(link).to.have.class 'selected'

        it 'renders switch for high contrast theme', ->
          I18n.t.withArgs('themes.names.athens').returns 'High contrast'
          view.render()
          link = view.$('#coreon-footer .themes a[data-name]').eq(1)
          expect(link).to.have.data 'name', 'athens'
          expect(link).to.have.text 'High contrast'
          expect(link).to.not.have.class 'selected'

    context "without session", ->

      beforeEach ->
        @stub Backbone.history, "stop"
        view.$el.append '<div id="coreon-main"></div>'

      it "disables history", ->
        view.render()
        Backbone.history.stop.should.have.been.calledOnce

      it "switches to login screen", ->
        view.$el.html '''
          <div id="coreon-main"></div>
        '''
        constructor = Coreon.Views.Sessions.NewSessionView
        view.render()
        expect(constructor).to.have.been.calledOnce
        expect(constructor).to.have.been.calledWith model: app
        main = view.$('#coreon-main')[0]
        expect($.contains main, login.el).to.be.true
        subviews = view.subviews
        expect(subviews).to.include login

      it "does not render widgets", ->
        view.render()
        view.$el.should.not.have "#coreon-widgets"

      it "does not render footer", ->
        view.render()
        view.$el.should.not.have "#coreon-footer"

  describe "notify()", ->

    beforeEach ->
      @stub Coreon.Views.Notifications, "NotificationView", =>
        @info = new Backbone.View
        @info.render = @stub().returns @info
        @info.show = @spy()
        @info
      @collection = new Backbone.Collection
      @stub Coreon.Models.Notification, "collection", => @collection
      view.render()

    it "is triggered when notification was added", ->
      view.notify = @spy()
      view.initialize()
      @collection.trigger "add", message: "I preferred to be called Nobody.", @collection, by: "Nobody"
      view.notify.should.have.been.calledOnce
      view.notify.should.have.been.calledWith message: "I preferred to be called Nobody.", @collection, by: "Nobody"

    it "creates notification view", ->
      notification = new Backbone.Model
      view.notify notification
      Coreon.Views.Notifications.NotificationView.should.have.been.calledOnce
      Coreon.Views.Notifications.NotificationView.should.have.been.calledWithNew
      Coreon.Views.Notifications.NotificationView.should.have.been.calledWith model: notification

    it "appends notification", ->
      $("#konacha").append view.$el
      view.notify new Backbone.Model
      @info.render.should.have.been.calledOnce
      $.contains($("#coreon-notifications")[0], @info.el).should.be.true

    it "reveals notification", ->
      $("#konacha").append view.$el
      view.notify new Backbone.Model
      @info.$el.should.be.hidden
      @info.show.should.have.been.calledOnce

  describe "syncOffset()", ->

    beforeEach ->
      @stub Coreon.Views.Notifications, "NotificationView", =>
        @info = new Backbone.View
        @info.show = ->
        @info

    it "is triggered on notification resize", ->
      view.syncOffset = @spy()
      view.notify new Backbone.Model
      @info.trigger "resize"
      view.syncOffset.should.have.been.calledOnce

  describe "clearNotifications()", ->

    beforeEach ->
      @collection = new Backbone.Collection
      @stub Coreon.Models.Notification, "collection", => @collection
      view.render()

    it "is triggered when notifications are reset", ->
      view.clearNotifications = @spy()
      view.initialize()
      @collection.trigger "reset", []
      view.clearNotifications.should.have.been.calledOnce

    it "clears notifications", ->
      notification = new Backbone.Model
      view.initialize()
      view.notify notification
      view.$("#coreon-notifications").first().children().length.should.equal 1
      @collection.trigger "reset", []
      view.$("#coreon-notifications").first().children().length.should.equal 0


  describe "navigate()", ->

    beforeEach ->
      @stub Backbone.history, "navigate"
      view.$el.append '''
        <a id="inside" href="/path">Click me</a>
        <a id="outside" href="http://url">Click me</a>
      '''
      @event = $.Event "click"
      @event.target = view.$("a#inside")[0]

    it "is triggered by click on internal link", ->
      view.navigate = @spy()
      view.delegateEvents()
      view.$("a#inside").trigger @event
      view.navigate.should.have.been.calledOnce
      view.navigate.should.have.been.calledWith @event

    it "is not triggered by click on external link", ->
      view.navigate = @spy()
      view.delegateEvents()
      @event.target = view.$("a#outside")[0]
      view.$("a#outside").trigger @event
      view.navigate.should.not.have.been.called

    it "prevents default", ->
      @event.preventDefault = @spy()
      view.navigate @event
      @event.preventDefault.should.have.been.calledOnce

    it "calls navigate on history", ->
      $(@event.target).attr "href", "/logout"
      view.navigate @event
      Backbone.history.navigate.should.have.been.calledOnce
      Backbone.history.navigate.should.have.been.calledWith "logout", trigger: yes

    it "can have nested elements", ->
      view.$el.append '<a id="nested" href="/foo"><p>Inner</p></a>'
      @event.target = view.$("#nested p")[0]
      view.navigate @event
      Backbone.history.navigate.should.have.been.calledOnce
      Backbone.history.navigate.should.have.been.calledWith "foo", trigger: yes

  describe "reauthenticate()", ->

    beforeEach ->
      Coreon.application.cacheId = -> "coffee23"
      @stub Coreon.Views.Account, "PasswordPromptView", =>
        @prompt = new Backbone.View
      @session = new Backbone.Model
        auth_token: "supersecrettoken"
        user:
          name: "Nobody"
      @session.currentRepository = ->
      view.model.set "session", @session

    afterEach ->
      Coreon.application.cacheId = null

    it "is triggered by changes on session token", ->
      view.reauthenticate = @spy()
      view.updateSession()
      @session.set "auth_token", "someothersecrettoken"
      view.reauthenticate.callCount.should.equal 1
      view.reauthenticate.firstCall.args[0].should.equal @session
      view.reauthenticate.firstCall.args[1].should.equal "someothersecrettoken"

    it "can prompt", ->
      should.exist Coreon.Modules.Prompt
      view.prompt.should.equal Coreon.Modules.Prompt.prompt

    it "displays password prompt when token is not set", ->
      view.prompt = @spy()
      view.reauthenticate @session, null
      Coreon.Views.Account.PasswordPromptView.callCount.should.equal 1
      Coreon.Views.Account.PasswordPromptView.should.have.been.calledWithNew
      Coreon.Views.Account.PasswordPromptView.firstCall.args[0].should.eql model: @session
      view.prompt.callCount.should.equal 1
      view.prompt.firstCall.args[0].should.equal @prompt

    it "hides password prompt when token is set", ->
      view.prompt = @spy()
      view.reauthenticate @session, "newcoolsessiontoken"
      Coreon.Views.Account.PasswordPromptView.should.not.have.been.called
      view.prompt.should.have.been.calledOnce
      view.prompt.should.have.been.calledWith null

  describe "repository()", ->

    beforeEach ->
      @session = new Backbone.Model
      @session.currentRepository = -> null
      view.model.set "session", @session, silent: yes

    it "returns current repository when no id is given", ->
      repository = new Backbone.Model
      @session.currentRepository = -> repository
      view.repository().should.equal repository

    it "doesn't switch to default repository when no id is given", ->
      repository = new Backbone.Model
      @session.currentRepository = -> repository
      @session.set = @spy()
      view.repository().should.equal repository
      @session.set.should.not.have.been.called

    it "returns null without a session", ->
      view.model.set "session", null, silent: yes
      should.equal view.repository(), null

    it "selects current repository when id is passed", ->
      view.repository "myrepositoryzuio"
      view.model.get("session").get("current_repository_id").should.equal "myrepositoryzuio"

  describe '#updateQuery()', ->

    input = null
    hint = null

    beforeEach ->
      $('#konacha').append view.$el
      view.$el.append '''
        <input id="coreon-search-query" type="text" name="q" value=""/>
        <div id="coreon-search-target-select">
          <p class="hint">I am a hint</p>
        </div>
      '''
      input = view.$('#coreon-search-query')
      hint = view.$('#coreon-search-target-select .hint')

    it 'is triggerd when query changes', ->
      update = @spy()
      view.updateQuery = update
      view.initialize()
      view.model.trigger 'change:query'
      expect(update).to.have.been.calledOnce
      expect(update).to.have.been.calledOn view

    it 'sets value on search input', ->
      view.model.set 'query', 'poet', silent: yes
      view.updateQuery()
      expect(input).to.have.value 'poet'

    it 'hides hint when query is not empty', ->
      view.model.set 'query', 'poet', silent: yes
      view.updateQuery()
      expect(hint).to.be.hidden

    it 'shows hint when query is empty', ->
      view.model.set 'query', '', silent: yes
      view.updateQuery()
      expect(hint).to.be.visible

  describe "toggle()", ->

    beforeEach ->
      $("#konacha").append view.$el
      view.$el.append '''
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
      @event.target = view.$(".toggle h3")[0]

    it "is triggered by click on toggle", ->
      view.toggle = @spy()
      view.delegateEvents()
      view.$(".toggle").trigger @event
      view.toggle.should.have.been.calledOnce

    it "toggles siblings", ->
      view.toggle @event
      view.$("#coreon-account").should.be.hidden
      view.toggle @event
      view.$("#coreon-account").should.be.visible

  describe '#switchTheme()', ->

    link = null
    event = null

    beforeEach ->
      $('#konacha').html '''
        <a id="coreon-theme" rel="stylesheet" href="athens.css">
      '''
      view.$el.html '''
        <div class="themes">
          <a href="javascript:void(0)" data-name="berlin">Default</a>
        </div>
      '''
      link = view.$('a')
      event = $.Event 'click'
      event.target = link[0]

    it 'is triggered by click on theme switch', ->
      switchTheme = @spy()
      view.switchTheme = switchTheme
      view.delegateEvents()
      link.trigger event
      expect(switchTheme).to.have.been.calledOnce
      expect(switchTheme).to.have.been.calledOn view
      expect(switchTheme).to.have.been.calledWith event

    it 'prevents default', ->
      preventDefault = @spy()
      event.preventDefault = preventDefault
      view.switchTheme event
      expect(preventDefault).to.have.been.calledOnce

    it 'switches link to stylesheet', ->
      style = $('#coreon-theme')
      style.attr 'href', 'assets/athens.css?body=1'
      view.switchTheme event
      expect(style).to.have.attr 'href', 'assets/berlin.css?body=1'

    it 'marks current switch es selected', ->
      other = $('<a href="javascript:void(0)" data-name="athens">Other</a>')
      view.$('.themes').append other
      view.switchTheme event
      expect(other).to.not.have.class 'selected'
      expect(link).to.have.class 'selected'
