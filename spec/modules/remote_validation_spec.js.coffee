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

    it "skips empty arrays", ->
      @model.trigger "error", @model,
        responseText: '{"errors":{"foo":[],"bar":["must be foo"]}}'
      @model.remoteError.should.eql bar: ["must be foo"]

    it "does not set empty errors hash", ->
      @model.trigger "error", @model,
        responseText: '{"errors":{"foos":[]}}'
      should.equal @model.remoteError, null

    it "is cleared on successful sync", ->
      @model.remoteError = foo: ["must be bar"]
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

    it "combines nested errors", ->
      @model.validationError =
        nested_errors_on_foo: [ bar: ["must be baz"] ]
      @model.remoteError =
        nested_errors_on_foo: [ bar: ["must not be foo"], baz: ["must not be bar"] ]
      @model.errors().nested_errors_on_foo.should.eql [
        bar: ["must not be foo", "must be baz"]
        baz: ["must not be bar"]
      ]

    it "combines nested errors on nested errors", ->
      @model.validationError =
        nested_errors_on_foo: [ nested_errors_on_bar: [ baz: ["must not be foo"] ] ]
      @model.remoteError =
        nested_errors_on_foo: [ nested_errors_on_bar: [ baz: ["must not be baz"] ] ]
      @model.errors().nested_errors_on_foo.should.eql [
        nested_errors_on_bar: [ baz: ["must not be baz", "must not be foo"] ]
      ]
