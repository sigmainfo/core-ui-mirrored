#= require spec_helper
#= require modules/helpers
#= require modules/remote_validation

describe "Coreon.Modules.RemoteValidation", ->

  before ->
    class Coreon.Models.MyModel extends Backbone.Model
      Coreon.Modules.include @, Coreon.Modules.RemoteValidation

  after ->
    delete Coreon.Models.MyModel

  beforeEach ->
    @model = new Coreon.Models.MyModel

  describe "remoteError", ->

    beforeEach ->
      @model.remoteValidationOn()

    it "defaults to null", ->
      should.equal @model.remoteError, null

    it "is set on xhr error", ->
      @model.trigger "error", @model,
        responseText: '{"errors":{"foo":["must be bar"]}}'
      @model.remoteError.should.eql foo: ["must be bar"]

    it "interpolates nested errors", ->
      @model.trigger "error", @model,
        responseText: '{"errors":{"foos":["is invalid"], "nested_errors_on_foos":["must be bar"]}}'
      @model.remoteError.should.eql foos: ["must be bar"]

    it "is cleared on successful sync", ->
      @model.remoteError = {foo: ["must be bar"]}
      @model.trigger "sync"
      should.equal @model.remoteError, null

  describe "errors()", ->
      
    it "defaults to null", ->
      should.equal @model.errors(), null

    it "combines local and remote errors", ->
      @model.validationError =
        foo: ["must be bar"]
      @model.remoteError =
        foo: ["must not be baz"]
        bar: ["must be foo"]
      @model.errors().should.eql
        foo: ["must not be baz", "must be bar"]
        bar: ["must be foo"]

    it "skips duplicates", ->
      @model.validationError =
        foo: ["must be bar"]
      @model.remoteError =
        foo: ["must be bar"]
      @model.errors().foo.should.eql ["must be bar"]
      
    
