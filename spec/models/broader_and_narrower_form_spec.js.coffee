#= require spec_helper
#= require models/broader_and_narrower_form

describe "Coreon.Models.BroaderAndNarrowerForm", ->

  beforeEach ->
    @concept = new Backbone.Model
      id: "c0ffee"
      superconcept_ids: ["daddee"]
      subconcept_ids: ["babee"]
      label: "coffee"
    @model = new Coreon.Models.BroaderAndNarrowerForm {}, concept:@concept

  it "is a Backbone model", ->
    @model.should.been.an.instanceof Backbone.Model
    
  it "delivers original model id", ->
    @model.id.should.equal "c0ffee"

  it "delivers superconcept ids", ->
    @model.get("superconcept_ids").should.be.instanceOf Array
    @model.get("superconcept_ids").should.eql ["daddee"]

  it "delivers subconcept ids", ->
    @model.get("subconcept_ids").should.be.instanceOf Array
    @model.get("subconcept_ids").should.eql ["babee"]

  it "delivers label", ->
    @model.get("label").should.equal "coffee"

  it "fascades isNew()", ->
    @concept.isNew = -> true
    @model.isNew().should.be.true
    @concept.isNew = -> false
    @model.isNew().should.be.false

  it "ignores doublettes", ->
    @model.set "superconcept_ids", ["daddaa", "daddaa"]
    @model.get("superconcept_ids").should.eql ["daddaa"]
    @model.set "subconcept_ids", ["bibii", "bibii"]
    @model.get("subconcept_ids").should.eql ["bibii"]

  it "doesn't propagate changes", ->
    @concept.set "superconcept_ids", ["daddee"]
    @concept.set "subconcept_ids", ["babee"]
    @model.set "superconcept_ids", ["daddee", "daddaa"]
    @model.set "subconcept_ids", ["babee", "bibii"]
    @concept.get("superconcept_ids").should.eql ["daddee"]
    @concept.get("subconcept_ids").should.eql ["babee"]

