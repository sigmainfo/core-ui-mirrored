#= require spec_helper
#= require views/application_view

describe "Coreon.Views.ApplicationView", ->

  beforeEach ->
    @view = new Coreon.Views.ApplicationView
      el: "#konacha"
      model:
        notifications: new Backbone.Collection
        account:
          idle: -> false

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  describe "#initialize", ->
    
    it "creates footer subview", ->
      @view.model = "Application"
      @view.initialize()
      @view.footer.should.be.an.instanceOf Coreon.Views.FooterView
      @view.footer.model.should.equal @view.model

    it "creates tools subview", ->
      @view.model = "Application"
      @view.initialize()
      @view.tools.should.be.an.instanceOf Coreon.Views.ToolsView
      @view.tools.model.should.equal @view.model

    
  describe "#render", ->

    it "allows chaining", ->
      @view.render().should.equal @view

    it "clears content before rendering", ->
      $("#konacha").append $("<div>", id: "foo")
      @view.render()
      @view.$el.should.not.have "#foo"

    describe "footer", ->

      it "appends element when logged in", ->
        @view.model.account.idle = -> false
        @view.render()
        @view.$el.should.have "#coreon-footer"

      it "does not append element when not logged in", ->
        @view.model.account.idle = -> true
        @view.render()
        @view.$el.should.not.have "#coreon-footer"

    it "appends tools element", ->
      @view.render()
      @view.$el.should.have "#coreon-tools"

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
