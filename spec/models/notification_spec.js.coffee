#= require spec_helper
#= require models/notification

describe "Coreon.Models.Notification", ->
  
  beforeEach ->
    @notification = new Coreon.Models.Notification

  it "is a Backbone model", ->
    @notification.should.be.an.instanceOf Backbone.Model

  context "hidden:", ->

    it "defaults to false", ->
      @notification.get("hidden").should.be.false
