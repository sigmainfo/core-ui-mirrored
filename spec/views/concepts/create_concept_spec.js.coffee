#= require spec_helper
#= require views/concepts/create_concept_view
#= require models/concept

describe "Coreon.Views.Concepts.CreateConceptView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Concepts.CreateConceptView

  afterEach ->
    I18n.t.restore()

  
