#= require spec_helper
#= require collections/concepts

describe "Coreon.Collections.Concepts", ->
  
  beforeEach ->
    @collection = new Coreon.Collections.Concepts
    Coreon.application =
      account:
        connections:
          sync: Backbone.sync

  it "is a Backbone collection", ->
    @collection.should.be.an.instanceOf Backbone.Collection

  it "uses Concept model", ->
    @collection.model.should.equal Coreon.Models.Concept
    
  it "generates url", ->
    Coreon.application.account = get: sinon.stub();
    Coreon.application.account.get.withArgs("graph_root").returns("https://api.coreon/graph/")
    @collection.url().should.equal "https://api.coreon/graph/concepts"

  describe "#get", ->

    context "when already loaded", ->

      beforeEach ->
        @model = _(new Backbone.Model id: "1234abcf").extend
          fetch: sinon.spy()
        @collection.add @model

      it "returns existing model from collection", ->
        @collection.get("1234abcf").should.equal @model
        @collection.length.should.equal 1
        @collection.at(0).should.equal @model
        @model.fetch.should.not.have.been.called

    context "when not yet loaded", ->

      beforeEach ->
        @collection.on "add", (@model) =>
          @model.fetch = sinon.spy()

      it "adds model when not existing", ->
        @collection.on "add", ->, 
        @collection.get("1234abcf").should.equal @collection.at(0)  

      it "fetches newly created model", () ->
        @collection.get("1234abcf")
        @model.fetch.should.have.been.calledOnce
