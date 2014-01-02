#= require spec_helper
#= require models/term_list

describe 'Coreon.Models.TermList', ->

  beforeEach ->
    @model = new Coreon.Models.TermList

  it 'is a Backbone model', ->
    expect( @model ).to.be.an.instanceof Backbone.Model
