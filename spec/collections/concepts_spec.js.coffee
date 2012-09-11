#= require spec_helper
#= require collections/concepts
#= require config/application

describe "Coreon.Collections.Concepts", ->
  
  beforeEach ->
    @collection = new Coreon.Collections.Concepts
    Coreon.application = new Coreon.Application

  afterEach ->
    Coreon.application.destroy()

  it "is a Backbone collection", ->
    @collection.should.be.an.instanceOf Backbone.Collection

  it "uses Concept model", ->
    @collection.model.should.equal Coreon.Models.Concept

  it "defines concepts path", ->
    @collection.url.should.equal "concepts"
    
  describe "#getOrFetch", ->

    context "when already loaded", ->

      beforeEach ->
        @model = _(new Backbone.Model _id: "1234abcf").extend
          fetch: sinon.spy()
        @collection.add @model

      it "returns existing model from collection", ->
        @collection.getOrFetch("1234abcf").should.equal @model
        @collection.length.should.equal 1
        @collection.at(0).should.equal @model
        @model.fetch.should.not.have.been.called

    context "when not yet loaded", ->

      beforeEach ->
        @collection.on "add", (@model) =>
          @model.fetch = sinon.spy()

      it "adds model when not existing", ->
        @collection.on "add", ->, 
        @collection.getOrFetch("1234abcf").should.equal @collection.at(0)  

      it "fetches newly created model", () ->
        @collection.getOrFetch("1234abcf")
        @model.fetch.should.have.been.calledOnce

  describe "#addOrUpdate", ->
    
    beforeEach ->
      @collection.add [
        {_id: "c1"}
        {_id: "c2"}
        {_id: "c3"}
      ]

    it "adds concept not yet in the collection", ->
      @collection.on "add", (@added) =>
      @collection.addOrUpdate _id: "c9"
      @collection.should.have.length 4
      @added.should.have.property "id", "c9"

    it "updates existing model", ->
      @collection.addOrUpdate _id: "c1", foo: "bar"
      @collection.get("c1").has("foo").should.be.true

    it "takes attributes list", ->
      @collection.addOrUpdate [
       {_id: "c2", foo: "bar"}
       {_id: "c9", foo: "baz"}
      ]
      @collection.should.have.length 4
      @collection.get("c2").get("foo").should.equal "bar"
      @collection.get("c9").get("foo").should.equal "baz"
