#= require spec_helper
#= require views/notifications_view

describe "Coreon.Views.NotificationsView", ->

  beforeEach ->
    @view = new Coreon.Views.NotificationsView
      collection: new Backbone.Collection [
        { message: "The kid" },
        { message: "What?" }, 
        { message: "Did the kid see it?" }
      ]

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  it "creates list container", ->
    @view.$el.should.be "ul.notifications"

  context "#render", ->

    it "allows chaining", ->
      @view.render().should.equal @view

    it "renders notifications", ->
      @view.render()
      @view.$(".notification").size().should.equal 3
      @view.$(".notification").first().should.contain "The kid"

    it "clears view before rendering new elements", ->
      @view.$el.append $("<div>", "class": "notification")
      @view.render()
      @view.$(".notification").size().should.equal 3

    it "is triggered on reset", ->
      @view.collection.reset message: "You know, we're all going to be really glad when we get rid of you, Somerset."
      @view.$(".notification").size().should.equal 1
      @view.$(".notification").first().should.contain "You know, we"

  context "#onAdd", ->

    beforeEach ->
      @view.render()

    it "prepends notification view", ->
      @view.collection.add message: "What the fuck sort of question is that?"
      @view.$(".notification").size().should.equal 4
      @view.$(".notification").first().should.contain "What the fuck sort of question is that?"

  context "#clear", ->

    beforeEach ->
      @view.render()

    it "empties notification list", ->
      @view.clear()
      @view.$el.should.be ":empty"      



