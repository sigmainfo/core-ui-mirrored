#= require spec_helper
#= require views/application_view

describe "Coreon.Views.ApplicationView", ->
  
  beforeEach ->
    @view = new Coreon.Views.ApplicationView
      model: new Backbone.Model

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
        @view.model.set "session", new Backbone.Model, silent: on

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
