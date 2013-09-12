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
        id: "abcd1234"
        admin: {author: "Nobody"}
        terms : [ "foo", "bar" ]
        created_at: '2013-09-12 13:48'
        updated_at: '2013-09-12 13:50'
      }, silent: true
      @model.info().should.eql
        id: "abcd1234"
        author: "Nobody"
        created_at: '2013-09-12 13:48'
        updated_at: '2013-09-12 13:50'

