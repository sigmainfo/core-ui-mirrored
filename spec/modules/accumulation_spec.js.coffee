#= require spec_helper
#= require modules/accumulation

describe "Coreon.Modules.Accumulation", ->

  before ->
    class Coreon.Models.MyModel extends Backbone.Model

      _(@).extend Coreon.Modules.Accumulation

      idAttribute: "_id"

      sync: ->

  after ->
    delete Coreon.Models.MyModel

  afterEach ->
    Coreon.Models.MyModel.collection().reset() 

  describe "#collection", ->

    it "is a Backbone collection", ->
      Coreon.Models.MyModel.collection().should.be.an.instanceof Backbone.Collection

    it "is empty by default", ->
      Coreon.Models.MyModel.collection().isEmpty().should.be.true

    it "has model class set to self", ->
      Coreon.Models.MyModel.collection().model.should.equal Coreon.Models.MyModel


  describe "#find", ->

    context "on unknown model", ->
      
      it "returns new model instance", ->
        model = Coreon.Models.MyModel.find "123"
        model.should.be.an.instanceof Coreon.Models.MyModel

      it "adds model to collection", ->
        model = Coreon.Models.MyModel.find "123"
        Coreon.Models.MyModel.collection().get("123").should.equal model

      it "fetches model", ->
        Coreon.Models.MyModel.collection().on "add", (model) =>
          model.fetch = sinon.spy()
        model = Coreon.Models.MyModel.find "123"
        model.fetch.should.have.been.calledOnce
        

    context "on already loaded model", ->

      it "returns model from collection", ->
        model = new Coreon.Models.MyModel _id: "123"
        Coreon.Models.MyModel.collection().add model
        Coreon.Models.MyModel.find("123").should.equal model

  describe "#upsert", ->

    beforeEach ->
      @original = new Coreon.Models.MyModel
        _id: "123"
        profession: "poet"
      Coreon.Models.MyModel.collection().add @original
  
    context "passing single attributes hash", ->

      it "updates existing model", ->
        model = Coreon.Models.MyModel.upsert
          _id: "123"
          profession: "killer"
        model.should.equal @original
        Coreon.Models.MyModel.find("123").should.equal model
        model.get("profession").should.equal "killer"

      it "inserts new model", ->
        model = Coreon.Models.MyModel.upsert
          _id: "777"
          profession: "cowboy"
        Coreon.Models.MyModel.find("777").should.equal model
        model.should.be.an.instanceof Coreon.Models.MyModel
        model.id.should.equal "777"
        model.get("profession").should.equal "cowboy"

    context "passing multiple attributes hashes", ->
      
      it "upserts and returns all affected models", ->
        models = Coreon.Models.MyModel.upsert [
          { _id: "123", profession: "killer" }
          { _id: "777", profession: "cowboy" }
        ]
        models.should.eql [
          Coreon.Models.MyModel.find "123" 
          Coreon.Models.MyModel.find "777" 
        ]