#= require spec_helper
#= require views/account/show_view

describe "Coreon.Views.Account.ShowView", ->
  
  beforeEach ->
    @view = new Coreon.Views.Account.ShowView

  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  it "creates container", ->
    @view.$el.should.have.id "coreon-account"
    
  context "#render", ->

    it "allows chaining", ->
      @view.render().should.equal @view
    
    it "renders logout link", ->
      @view.render()
      @view.$el.should.have "a:contains(#{I18n.t 'account.logout'})"
      @view.$("a").should.have.attr "href", "/account/logout"
