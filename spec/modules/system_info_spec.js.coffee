#= require spec_helper
#= require modules/helpers
#= require modules/system_info

describe "Coreon.Modules.SystemInfo", ->

  before ->
    class Coreon.Models.MyModel extends Backbone.Model
      Coreon.Modules.include @, Coreon.Modules.SystemInfo
      defaults: -> {}

  after ->
    delete Coreon.Models.MyModel

  beforeEach ->
    @model = new Coreon.Models.MyModel

  describe "info()", ->

    it "returns hash with system info attributes", ->
      @model.defaults = -> terms: []
      @model.set {
        _id: "abcd1234"
        author: "Nobody"
        terms : [ "foo", "bar" ]
      }, silent: true
      @model.info().should.eql
        id: "abcd1234"
        author: "Nobody"
