#= require spec_helper
#= require models/connection

describe "Coreon.Models.Connection", ->
  
  beforeEach ->
    @xhr = sinon.useFakeXMLHttpRequest()
    @xhr.onCreate = (@request) =>
    @connection = new Coreon.Models.Connection
      xhr: $.ajax("/some/url")

  afterEach ->
    @xhr.restore()

  it "is a Backbone model", ->
    @connection.should.be.an.instanceof Backbone.Model

  describe "on complete", ->

    it "removes itself from collection when completed", ->
      collection = new Backbone.Collection
      collection.add @connection
      @request.respond()
      collection.length.should.equal 0
     

  describe "on error", ->

    beforeEach ->
      sinon.stub I18n, "t"
      @connection.message = sinon.spy()

    afterEach ->
      I18n.t.restore()

    it "creates generic error message by default", ->
      I18n.t.withArgs("errors.generic").returns "An error occurred"
      @request.respond 500, {}, ""
      @connection.message.should.have.been.calledWith "An error occurred", type: "error"

    it "creates specific error when given", ->
      I18n.t.withArgs("errors.json.parse").returns "Could not parse JSON"
      @request.respond 444, {}, JSON.stringify
        code: "errors.json.parse"
      @connection.message.should.have.been.calledWith "Could not parse JSON"

    it "uses provided message as fallback", ->
      I18n.t.withArgs("does.not.exist", defaultValue: "I'm not dead. Am I?").returns "I'm not dead. Am I?"
      @request.respond 444, {}, JSON.stringify
        code: "does.not.exist"
        message: "I'm not dead. Am I?"
      @connection.message.should.have.been.calledWith "I'm not dead. Am I?"

    it "creates special error when server is not available", ->
      I18n.t.withArgs("errors.service.unavailable").returns "Service unavailable"
      @request.respond 0, {}, ""
      @connection.message.should.have.been.calledWith "Service unavailable"
