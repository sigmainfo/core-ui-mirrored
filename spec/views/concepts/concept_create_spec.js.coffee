#= require spec_helper
#= require views/concepts/concept_create
#= require models/concept

describe "Coreon.Views.Concepts.ConceptCreate", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Concepts.ConceptCreate
      model: new Coreon.Models.Concept

  afterEach ->
    I18n.t.restore()

  
