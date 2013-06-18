#= require spec_helper
#= require views/layout/footer_view

describe "Coreon.Views.Layout.FooterView", ->
  
  beforeEach ->
    session = new Backbone.Model
    session.connections = new Backbone.Collection
    @view = new Coreon.Views.Layout.FooterView
      model: session

  it "is a composite view", ->
    @view.should.be.an.instanceOf Coreon.Views.CompositeView

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
      sinon.spy Coreon.Views.Account, "AccountView"
      @view.render()
      Coreon.Views.Account.AccountView.should.have.been.calledWith model: @view.model
      Coreon.Views.Account.AccountView.restore()

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

  describe "progress-indicator", ->

    it "creates view", ->
      @view.progress.should.be.an.instanceOf Coreon.Views.Layout.ProgressIndicatorView
      @view.progress.collection.should.equal @view.model.connections

    it "renders el", ->
      @view.progress.render = sinon.stub().returns @view.progress
      @view.render()
      @view.progress.render.should.have.been.calledOnce

    it "appends el", ->
      @view.render()
      @view.$(".toggle").should.have "#coreon-progress-indicator"
      
      
      
