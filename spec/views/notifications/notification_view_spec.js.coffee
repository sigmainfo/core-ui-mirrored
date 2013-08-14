#= require spec_helper
#= require models/notification
#= require views/notifications/notification_view

describe "Coreon.Views.Notifications.NotificationView", ->
  
  beforeEach ->
    @view = new Coreon.Views.Notifications.NotificationView
      model: new Backbone.Model

  it "is no simple view anymore", ->
    @view.should.be.an.instanceOf Backbone.View

  it "creates list element", ->
    @view.$el.should.be "li.notification"

  describe "render()", ->

    it "can be chained", ->
      @view.render().should.equal @view
    
    it "is triggered on model changes", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "change" 
      @view.render.should.have.been.calledOnce
    
    it "renders notification type", ->
      @view.model.set "type", "error", silent: true
      @view.render()
      @view.$el.should.have.class "error"

    it "replaces notification type", ->
      @view.model.set "type", "error", silent: true
      @view.render()
      @view.model.set "type", "info", silent: true
      @view.render()
      @view.$el.should.be ".notification.info"
      @view.$el.should.not.have.class "error"

    it "renders hide button", ->
      @view.model.id = "123"
      @view.model.url = -> "notifications/123"
      @view.render()
      @view.$el.should.have "span.actions a.hide"
      @view.$("a.hide").should.have.text I18n.t "notification.actions.hide"

    it "renders message", ->
      @view.model.set message: "If you kill him, he will win."
      @view.render()
      @view.$el.should.have "span.message"
      @view.$(".message").should.have.text "If you kill him, he will win."

  describe "close()", ->

    beforeEach ->
      @view.render()

    it "is triggered by click on hide button", ->
      @view.close = sinon.spy()
      @view.delegateEvents()
      @view.$(".hide").click()
      @view.close.should.have.been.calledOnce
  
    it "removes model from collection", ->
      collection = new Backbone.Collection
      collection.add @view.model
      @view.close()
      expect(collection.get @view.model).to.not.exist

  describe "hide()", ->

    beforeEach ->
      $("#konacha").append @view.render().$el

    it "is triggered when removed", ->
      @view.hide = sinon.spy()
      @view.initialize()
      @view.model.trigger "remove"
      @view.hide.should.have.been.calledOnce

    it "hides el", ->
      @view.hide()
      @view.$el.should.be.hidden
  
    it "removes el", ->
      @view.remove = sinon.spy()
      @view.hide()
      @view.remove.should.have.been.calledOnce

    it "triggers resize event during animation", ->
      @view.$el.slideUp = sinon.spy()
      spy = sinon.spy()
      @view.on "resize", spy
      @view.hide()
      @view.$el.slideUp.should.have.been.calledOnce
      @view.$el.slideUp.firstCall.args[0].step()
      spy.should.have.been.calledOnce
      
  describe "show()", ->

    beforeEach ->
      $("#konacha").append @view.render().$el
      @view.$el.hide()

    it "shows el", ->
      @view.show()
      @view.$el.should.not.be.hidden

    it "triggers resize event during animation", ->
      @view.$el.slideDown = sinon.spy()
      spy = sinon.spy()
      @view.on "resize", spy
      @view.show()
      @view.$el.slideDown.should.have.been.calledOnce
      @view.$el.slideDown.firstCall.args[0].step()
      spy.should.have.been.calledOnce

  describe "remove()", ->
  
    it "calls super", ->
      sinon.stub Backbone.View::, "remove"
      try
        @view.remove()
        Backbone.View::remove.should.have.been.calledOnce
        Backbone.View::remove.should.have.been.calledOn @view
      finally
        Backbone.View::remove.restore()

    it "releases all registered listeners", ->
      @view.off = sinon.spy()
      @view.remove()
      @view.off.should.have.been.calledOnce
      @view.off.firstCall.args.should.have.lengthOf 0
