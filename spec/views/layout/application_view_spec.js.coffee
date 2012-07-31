#= require spec_helper
#= require views/layout/application_view

describe "Coreon.Views.Layout.ApplicationView", ->

  beforeEach ->
    @view = new Coreon.Views.Layout.ApplicationView
      el: "#konacha"

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  context "#render", ->

    it "allows chaining", ->
      @view.render().should.equal @view

    it "appends footer", ->
      @view.render()
      @view.$el.should.have "#coreon-account"

    it "clears content before rendering", ->
      $("#konacha").append $("<div>", id: "foo")
      @view.render()
      @view.$el.should.not.have "#foo"
