#= require spec_helper
#= require models/notification
#= require views/notification_view

describe "Coreon.Views.NotificationView", ->
  
  beforeEach ->
    @view = new Coreon.Views.NotificationView
      model: new Coreon.Models.Notification

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  it "creates list element", ->
    @view.$el.should.be "li.notification"

  context "#render", ->

    it "renders label", ->
      @view.render()
      @view.$el.should.have "span.label"
      @view.$(".label").should.have.text I18n.t "notification.label.notice"
      
    it "renders hide button", ->
      @view.model.id = "123"
      @view.model.url = -> "notifications/123"
      @view.render()
      @view.$el.should.have "span.actions a.hide"
      @view.$("a.hide").should.have.text I18n.t "notification.actions.hide"
      @view.$("a.hide").should.have.attr "href", "/notifications/123/hide"

    it "renders message", ->
      @view.model.set message: "If you kill him, he will win."
      @view.render()
      @view.$el.should.have "span.message"
      @view.$(".message").should.have.text "If you kill him, he will win."

    it "allows chaining", ->
      @view.render().should.equal @view

    it "hides el when hidden", ->
      @view.model.set hidden: true, silent: true
      $("#konacha").append @view.$el
      @view.render()
      @view.$el.should.be.hidden

  context "#hide", ->
    
    beforeEach ->
      @event = new jQuery.Event "click"

    it "is triggered by hide button", ->
      sinon.spy @view, "hide"
      @view.delegateEvents()
      @view.render()
      @view.$("a.hide").trigger @event
      @view.hide.should.have.been.calledOnce

    it "changes model state", ->
      @view.hide @event
      @view.model.get("hidden").should.equal true

    it "cancels event propagation and default action", ->
      sinon.spy @event, "preventDefault"
      sinon.spy @event, "stopPropagation"
      @view.hide @event
      @event.preventDefault.should.have.been.calledOnce
      @event.stopPropagation.should.have.been.calledOnce

  context "#onChangeHidden", ->

    beforeEach ->
      $("#konacha").append @view.render().$el

    it "is triggered by change of model state", ->
      sinon.spy @view, "onChangeHidden"
      @view.initialize()
      @view.model.set "hidden", true
      @view.onChangeHidden.should.have.been.calledOnce

    it "hides view when hidden", ->
      sinon.spy @view.$el, "slideUp"
      @view.model.set "hidden", false, silent: true
      @view.model.set "hidden", true
      @view.$el.slideUp.should.have.been.calledWith "fast"

    it "reveals view when not hidden", ->
      @view.model.set "hidden", true, silent: true
      @view.model.set "hidden", false
      @view.$el.should.be.visible