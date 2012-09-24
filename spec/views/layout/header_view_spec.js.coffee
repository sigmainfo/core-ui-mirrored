#= require spec_helper
#= require views/layout/header_view

describe "Coreon.Views.Layout.HeaderView", ->

  beforeEach ->
    @view = new Coreon.Views.Layout.HeaderView
      collection: new Backbone.Collection
  
  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView

  it "creates element", ->
    @view.$el.should.have.id "coreon-header"
    
  describe "#initialize", ->
    
    it "creates notifications", ->
      @view.notifications.should.be.an.instanceof Coreon.Views.Notifications.NotificationsView
      @view.notifications.collection.should.equal @view.collection

  describe "#render", ->
    
    it "is chainable", ->
      @view.render().should.equal @view

    it "renders notifications", ->
      @view.collection.add { message: "Hello header" }, silent: true
      @view.render()
      @view.$el.should.have "#coreon-notifications"
      @view.$("#coreon-notifications").should.have ".notification"
