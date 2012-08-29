#= require spec_helper
#= require views/header_view

describe "Coreon.Views.Header", ->

  beforeEach ->
    @notifications = new Backbone.Collection
    @view = new Coreon.Views.HeaderView collection: @notifications
  
  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  it "creates element", ->
    @view.$el.should.have.id "coreon-header"
    
  describe "#initialize", ->
    
    it "creates notifications", ->
      @view.notifications.should.be.an.instanceof Coreon.Views.NotificationsView
      @view.notifications.collection.should.equal @notifications

  describe "#render", ->
    
    it "is chainable", ->
      @view.render().should.equal @view

    it "renders notifications", ->
      @notifications.add { message: "Hello header" }, silent: true
      @view.render()
      @view.$el.should.have "#coreon-notifications"
      @view.$("#coreon-notifications").should.have ".notification"
