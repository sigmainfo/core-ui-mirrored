#= require spec_helper
#= require views/layout/footer_view

describe "Coreon.Views.Layout.FooterView", ->
  
  before ->
    jQuery.fx.off = true

  after ->
    jQuery.fx.off = false

  beforeEach ->
    @view = new Coreon.Views.Layout.FooterView
      model:
        account: "Account"

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
      sinon.spy Coreon.Views.Account, "ShowView"
      @view.model = account: "Account"
      @view.render()
      Coreon.Views.Account.ShowView.should.have.been.calledWith model: "Account"
      Coreon.Views.Account.ShowView.restore()

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



