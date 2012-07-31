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
      $("#app").should.have "#coreon-account"

    it "uses specified container", ->
      @app.init el: "#konacha"
      $("#konacha").should.have "#coreon-account"


            
