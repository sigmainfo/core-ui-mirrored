#= require spec_helper
#= require views/layout/application_view

describe "Coreon.Views.Layout.ApplicationView", ->

  beforeEach ->
    @view = new Coreon.Views.Layout.ApplicationView
      el: "#konacha"

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View
    
  context "#render", ->

    beforeEach ->
      @view.model = account: "Account"

    it "allows chaining", ->
      @view.render().should.equal @view

    it "appends footer", ->
      @view.render()
      @view.$el.should.have "#coreon-footer"

    it "passes model to footer", ->
      sinon.spy Coreon.Views.Layout, "FooterView"
      @view.model = account: "Account"
      @view.render()
      Coreon.Views.Layout.FooterView.should.have.been.calledWith model: @view.model
      Coreon.Views.Layout.FooterView.restore()
      

    it "clears content before rendering", ->
      $("#konacha").append $("<div>", id: "foo")
      @view.render()
      @view.$el.should.not.have "#foo"

  context "navigating history", ->

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
