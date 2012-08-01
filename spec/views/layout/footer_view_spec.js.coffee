#= require spec_helper
#= require views/layout/footer_view

describe "Coreon.Views.Layout.FooterView", ->

  beforeEach ->
    @view = new Coreon.Views.Layout.FooterView

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View


  it "creates container", ->
    @view.$el.should.have.id "coreon-footer"
  
  context "#render", -> 

    it "allows chaining", ->
      @view.render().should.equal @view

    it "renders toggle", ->
      @view.render()
      @view.$el.should.have ".toggle"

    it "renders account", ->
      @view.render()
      @view.$el.should.have "#coreon-account"
      @view.$el.find("#coreon-account").should.not.be ":empty"
