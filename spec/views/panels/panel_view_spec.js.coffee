#= require spec_helper
#= require views/panels/panel_view

describe 'Coreon.Views.Panels.PanelView', ->

  view = null

  beforeEach ->
    view = new Coreon.Views.Panels.PanelView

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'applies class name', ->
    el = view.$el
    expect(el).to.have.class 'panel'

  describe '#widgetize()', ->

    it 'adds class to el', ->
      view.widgetize()
      el = view.$el
      expect(el).to.have.class 'widget'
