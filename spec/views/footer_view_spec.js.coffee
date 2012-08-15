#= require spec_helper
#= require views/footer_view

describe "Coreon.Views.FooterView", ->
  
  before ->
    jQuery.fx.off = true

  after ->
    jQuery.fx.off = false

  beforeEach ->
    @view = new Coreon.Views.FooterView
      model:
        account: new Backbone.Model

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
      @view.$("#coreon-account").should.not.be ":empty"

    it "passes model to account view", ->
      sinon.spy Coreon.Views, "AccountView"
      @view.render()
      Coreon.Views.AccountView.should.have.been.calledWith model: @view.model.account
      Coreon.Views.AccountView.restore()

  context "#toggle", -> 

    beforeEach ->
      @view.render().$el.appendTo $("#konacha")

    it "hides all content by default", ->
      @view.$("#coreon-account").should.not.be.visible

    it "toggles when clicking toggle", ->
      @view.$(".toggle").click()
      @view.$("#coreon-account").should.be.visible
      @view.$(".toggle").click()
      @view.$("#coreon-account").should.not.be.visible



