#= require spec_helper
#= require views/account/account_view

describe "Coreon.Views.Account.AccountView", ->
  
  beforeEach ->
    @view = new Coreon.Views.Account.AccountView model: new Backbone.Model

  it "is a simple view", ->
    @view.should.be.an.instanceOf Coreon.Views.SimpleView

  it "creates container", ->
    @view.$el.should.have.id "coreon-account"

  context "#render", ->

    it "allows chaining", ->
      @view.render().should.equal @view
    
    it "renders login name", ->
      @view.model.set "name", "Big George"
      @view.render()
      @view.$el.should.contain I18n.t "account.status", name: "Big George"
      
    it "renders logout link", ->
      @view.render()
      @view.$el.should.have "a.logout"
      @view.$("a.logout").should.have.attr "href", "/account/logout"
      @view.$("a.logout").should.have.text I18n.t "account.logout"

  context "#logout", ->

    beforeEach ->
      Backbone.history = new Backbone.History
      @view.model.deactivate = ->
      @event = new jQuery.Event "click"

    afterEach ->
      Backbone.history.stop()
      Backbone.history = null
      
    it "handles clicks on logout link", ->
      sinon.spy @view, "logout"
      @view.delegateEvents()
      @view.render()
      @view.$("a.logout").trigger @event
      @view.logout.should.have.been.calledOnce

    it "terminates propagation and default action", ->
      sinon.spy @event, "preventDefault"
      sinon.spy @event, "stopPropagation"
      @view.logout @event
      @event.preventDefault.should.have.been.calledOnce
      @event.stopPropagation.should.have.been.calledOnce

    it "calls logout on model", ->
      @view.model.deactivate = sinon.spy()
      @view.logout @event
      @view.model.deactivate.should.have.been.calledOnce
