#= require spec_helper
#= require collections/notifications

describe "Coreon.Collections.Notifications", ->
  
  beforeEach ->
    @notifications = new Coreon.Collections.Notifications

  it "is a Backbone collection", ->
    @notifications.should.be.an.instanceOf Backbone.Collection

  it "defines model class", ->
    @notifications.model.should.equal Coreon.Models.Notification 

  it "creates virtual urls", ->
    @notifications.url.should.equal "notifications"

  describe "#destroy", ->

    it "resets collection", ->
      sinon.spy @notifications, "reset"
      @notifications.add message: "Things which are alike, in nature, grow to look alike." 
      @notifications.destroy()
      @notifications.reset.should.have.been.calledOnce
      @notifications.length.should.equal 0

