#= require spec_helper
#= require views/tools_view
#= require helpers/link_to

describe "Coreon.Views.ToolsView", ->
  
  beforeEach ->
    @view = new Coreon.Views.ToolsView 
      model:
        notifications: new Backbone.Collection
 
  it "is a Backbone view", ->
    @view.should.be.an.instanceOf Backbone.View

  it "creates container", ->
    @view.$el.should.have.id "coreon-tools"

  context "#render", ->
      
    it "allows chaining", ->
      @view.render().should.equal @view

    it "creates status bar", ->
      @view.render()
      @view.$el.should.have "#coreon-status"

    it "creates notification list", ->
      @view.model.notifications.add message: "Who gives a fuck?"
      @view.render()
      @view.$("#coreon-status").should.have "ul.notifications"
      @view.$("#coreon-status .notifications li").should.contain "Who gives a fuck?"

    it "renders search view", ->
      @view.render()
      @view.$el.should.have "#coreon-widgets #coreon-search"
      @view.$("#coreon-search").should.have "input#coreon-search-query"
      
