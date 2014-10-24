#= require spec_helper
#= require models/property

describe "Coreon.Models.Property", ->

  beforeEach ->
    @model = new Coreon.Models.Property

  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model

  describe "defaults()", ->

    it "returns a hash of standard attrs", ->
      @model.defaults().should.eql
        key: ""
        value: null
        lang: null

  describe "info()", ->

    it "returns hash with system info attributes", ->
      @model.defaults = ->
        key: ""
        value: null
        lang: null
      @model.set {
        id: "abcd1234"
        admin: {author: "Nobody"}
        key: "label"
        value: "hat"
        created_at: '2013-09-12 13:48'
        updated_at: '2013-09-12 13:50'
      }, silent: true
      @model.info().should.eql
        id: "abcd1234"
        author: "Nobody"
        created_at: '2013-09-12 13:48'
        updated_at: '2013-09-12 13:50'

