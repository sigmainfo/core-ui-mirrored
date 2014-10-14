#= require environment
#= require views/properties/edit_properties_view

describe 'Coreon.Views.Properties.EditPropertiesView', ->

  view = null
  collection  = null

  beforeEach ->
    collection = []
    view = new Coreon.Views.Properties.EditPropertiesView
      collection: collection

  it 'is a Backbone view', ->
    view.should.be.an.instanceof Backbone.View

  it 'has a template', ->
    view.should.have.property 'template'

  describe '#render()', ->

