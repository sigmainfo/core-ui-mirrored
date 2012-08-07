#= require spec_helper
#= require views/notifications/show_view

describe "Coreon.Views.Notifications.ShowView", ->

  beforeEach ->
    @view = new Coreon.Views.Notifications.ShowView

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View
