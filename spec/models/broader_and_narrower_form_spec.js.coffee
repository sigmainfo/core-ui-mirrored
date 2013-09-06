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
    
  it "delivers original model id", ->
    @model.id.should.equal "c0ffee"

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

  it "ignores doublettes", ->
    @model.set "super_concept_ids", ["daddaa", "daddaa"]
    @model.get("super_concept_ids").should.eql ["daddaa"]
    @model.set "sub_concept_ids", ["bibii", "bibii"]
    @model.get("sub_concept_ids").should.eql ["bibii"]

  it "doesn't propagate changes", ->
    @concept.set "super_concept_ids", ["daddee"]
    @concept.set "sub_concept_ids", ["babee"]
    @model.set "super_concept_ids", ["daddee", "daddaa"]
    @model.set "sub_concept_ids", ["babee", "bibii"]
    @concept.get("super_concept_ids").should.eql ["daddee"]
    @concept.get("sub_concept_ids").should.eql ["babee"]

  it "keeps temporary changes when original concept changes", ->
    @model.set "super_concept_ids", ["daddee", "daddaa"]
    @concept.set "super_concept_ids", ["daddee", "diddie"]
    @model.get("super_concept_ids").sort().should.eql ["daddaa", "daddee", "diddie"]

    @model.set "sub_concept_ids", ["babee", "bibii"]
    @concept.set "sub_concept_ids", ["babee", "bubuu"]
    @model.get("sub_concept_ids").sort().should.eql ["babee", "bibii", "bubuu"]

