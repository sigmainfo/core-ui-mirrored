#= require environment
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
