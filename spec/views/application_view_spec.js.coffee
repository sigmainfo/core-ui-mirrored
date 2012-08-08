#= require spec_helper
#= require views/application_view

describe "Coreon.Views.ApplicationView", ->

  beforeEach ->
    @view = new Coreon.Views.ApplicationView
      el: "#konacha"
      model:
        notifications: new Backbone.Collection
        account: "Account"
  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View
    
  context "#render", ->

    it "allows chaining", ->
      @view.render().should.equal @view

    it "clears content before rendering", ->
      $("#konacha").append $("<div>", id: "foo")
      @view.render()
      @view.$el.should.not.have "#foo"

    describe "footer", ->

      it "appends element", ->
        @view.render()
        @view.$el.should.have "#coreon-footer"

      it "passes model to view", ->
        sinon.spy Coreon.Views, "FooterView"
        @view.render()
        Coreon.Views.FooterView.should.have.been.calledWith model: @view.model
        Coreon.Views.FooterView.restore()

    describe "tools", ->
      
      it "appends element", ->
        @view.render()
        @view.$el.should.have "#coreon-tools"

      it "passes model to view", ->
        sinon.spy Coreon.Views, "ToolsView"
        @view.render()
        Coreon.Views.ToolsView.should.have.been.calledWith model: @view.model
        Coreon.Views.ToolsView.restore()

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
