#= require spec_helper
#= require models/panel

describe 'Coreon.Models.Panel', ->

  panel = null

  beforeEach ->
    panel = new Coreon.Models.Panel

  it 'is a Backbone model', ->
    expect(panel).to.be.an.instanceOf Backbone.Model

  context 'defaults', ->

    it 'is a widget', ->
      widgetized = panel.get('widget')
      expect(widgetized).to.be.true

    it 'has no type', ->
      type = panel.get('type')
      expect(type).to.equal ''
