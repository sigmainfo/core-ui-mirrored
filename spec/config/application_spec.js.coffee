#= require spec_helper
#= require application

describe "Coreon.Application", ->

  beforeEach ->
    @app = new Coreon.Application

  describe "#init", ->
    
    it "allows chaining", ->
      @app.init().should.equal @app

    it "uses #app by default", ->
      $("#konacha").append $("<div>", id: "app")
      @app.init()
      $("#app").should.have "#coreon-footer"

    it "uses specified container", ->
      @app.init el: "#konacha"
      $("#konacha").should.have "#coreon-footer"
    
    it "creates routers", ->
      sinon.spy Coreon.Routers, "AccountRouter"
      @app.init()
      Coreon.Routers.AccountRouter.should.have.been.calledOnce
      Coreon.Routers.AccountRouter.restore()

    it "starts history", ->
      sinon.spy Backbone.history, "start"
      @app.init()
      Backbone.history.start.should.have.been.calledWith pushState: true
      Backbone.history.start.restore()
