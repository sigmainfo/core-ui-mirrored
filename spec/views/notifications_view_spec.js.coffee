#= require spec_helper
#= require views/notifications_view

describe "Coreon.Views.NotificationsView", ->

  beforeEach ->
    @view = new Coreon.Views.NotificationsView

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View
