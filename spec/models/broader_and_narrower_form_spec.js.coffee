#= require spec_helper
#= require models/broader_and_narrower_form

describe "Coreon.Models.BroaderAndNarrowerForm", ->

  beforeEach ->
    @concept = new Backbone.Model
      _id: "c0ffee"
      super_concept_ids: ["daddee"]
      sub_concept_ids: ["babee"]
      label: "coffee"
    @model = new Coreon.Models.BroaderAndNarrowerForm @concept

  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model
    
  context "defaults", ->
    it "has empty sets for added/removed relations", ->
      @model.get("added_broader_relations").should.eql []
      @model.get("deleted_broader_relations").should.eql []
      @model.get("added_narrower_relations").should.eql []
      @model.get("deleted_narrower_relations").should.eql []


  it "delivers original model id", ->
    @model.get("concept_id").should.equal "c0ffee"

  it "delivers superconcept ids", ->
    @model.get("super_concept_ids").should.be.instanceOf Array
    @model.get("super_concept_ids").should.eql ["daddee"]

  it "delivers subconcept ids", ->
    @model.get("sub_concept_ids").should.be.instanceOf Array
    @model.get("sub_concept_ids").should.eql ["babee"]

  it "delivers label", ->
    @model.get("label").should.equal "coffee"

  it "updates superconcept ids", ->
    @concept.set "super_concept_ids", ["daddee", "daddaa"]
    @model.get("super_concept_ids").should.eql ["daddee", "daddaa"]

  it "updates subconcept ids", ->
    @concept.set "sub_concept_ids", ["babee", "bibii"]
    @model.get("sub_concept_ids").should.eql ["babee", "bibii"]

  it "updates label", ->
    @concept.set "label", "espresso"
    @model.get("label").should.equal "espresso"

  it "fascades isNew()", ->
    @concept.isNew = -> true
    @model.isNew().should.be.true
    @concept.isNew = -> false
    @model.isNew().should.be.false

