#= require spec_helper
#= require collections/concepts

describe "Coreon.Collections.Concepts", ->
  
  beforeEach ->
    @collection = new Coreon.Collections.Concepts
    Coreon.application =
      connections:
        sync: Backbone.sync

  it "is a Backbone collection", ->
    @collection.should.be.an.instanceOf Backbone.Collection

  describe "#fetch", ->

    beforeEach ->
      @xhr = sinon.useFakeXMLHttpRequest()
      @xhr.onCreate = (xhr) =>
        @request = xhr

    afterEach ->
      @xhr.restore()

    it "creates POST request on search url", ->
      @collection.url = "https://graph/concepts"
      @collection.fetch data: "q=dead+man"
      @request.method.should.equal "POST"
      @request.url.should.equal "https://graph/concepts/search"
      @request.requestBody.should.equal "q=dead+man"

  describe "#sync", ->

    afterEach ->
      delete Coreon.application

    it "delegates to connections.sync", ->
      Coreon.application =
        connections:
          sync: sinon.spy()
      @collection.sync "update", "Model", data: "data"
      Coreon.application.connections.sync.should.have.been.calledWith "update", "Model", data: "data"
