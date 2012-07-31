#= require spec_helper
#= require views/account/show_view

describe "Coreon.Views.Account.ShowView", ->
  
  beforeEach ->
    @view = new Coreon.Views.Account.ShowView

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  it "creates container", ->
    @view.$el.should.have.id "coreon-account"
    @view.$el.should.have.attr("class").match /footer/
    
  context "#render", ->

    it "allows chaining", ->
      @view.render().should.equal @view

    it "renders toggle", ->
      @view.render()
      @view.$el.should.have ".toggle"
