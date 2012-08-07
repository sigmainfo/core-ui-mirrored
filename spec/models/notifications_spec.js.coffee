#= require environment
#= require models/notifications

describe "Coreon.Models.Notifications", ->
  
  beforeEach ->
    @notifications = new Coreon.Models.Notifications

  it "is a Backbone collection", ->
    @notifications.should.be.an.instanceOf Backbone.Collection

  it "defines model class", ->
    @notifications.model.should.equal Coreon.Models.Notification 
