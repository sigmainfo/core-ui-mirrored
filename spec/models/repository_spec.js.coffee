#= require spec_helper
#= require models/repository

describe "Coreon.Models.Repository", ->

  beforeEach ->
    @model = new Coreon.Models.Repository

  it "is a Backbone model", ->
    @model.should.be.an.instanceof Backbone.Model

  context "defaults", ->

    it "creates empty set for managers", ->
      managers = @model.get "managers"
      expect( managers ).to.be.an.instanceOf Array
      expect( managers ).to.be.empty
      other = new Coreon.Models.Repository
      expect( managers ).to.not.equal other.get "managers"

  describe "#path()", ->

    it "returns repository path", ->
      @model.id = "345hjksdfg321"
      expect( @model.path() ).to.equal "/345hjksdfg321"
