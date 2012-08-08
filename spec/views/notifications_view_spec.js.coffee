#= require spec_helper
#= require views/notifications_view

describe "Coreon.Views.NotificationsView", ->

  beforeEach ->
    @view = new Coreon.Views.NotificationsView

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  it "creates list container", ->
    @view.$el.should.be "ul.notifications"

  context "#render", ->

    beforeEach ->
      @collection = new Coreon.Collections.Notifications [
        { message: "The kid" },
        { message: "What?" }, 
        { message: "Did the kid see it?" }
      ]
