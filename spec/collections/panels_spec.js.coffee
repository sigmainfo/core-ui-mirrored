#= spec_helper
#= require collections/panels

describe 'Coreon.Collections.Panels', ->

  context 'class', ->

    describe '.instance()', ->

      instance = null

      beforeEach ->
        instance = Coreon.Collections.Panels.instance()

      afterEach ->
        delete Coreon.Collections.Panels._instance

      it 'creates instance', ->
        constructor = Coreon.Collections.Panels
        expect(instance).to.be.an.instanceOf constructor

      it 'creates instance only once', ->
        result = Coreon.Collections.Panels.instance()
        expect(result).to.equal instance

      it 'creates default set of panels', ->
        types = instance.pluck 'type'
        expect(types).to.eql ['concepts', 'conceptMap', 'termList']

      it 'widgetizes all apnales execept the firs one', ->
        widgetized = instance.pluck 'widget'
        expect(widgetized).to.eql [off, on, on]

  context 'instance', ->

    panels = null

    beforeEach ->
      panels = new Coreon.Collections.Panels

    it 'is a Backbone collection', ->
      expect(panels).to.be.an.instanceOf Backbone.Collection

    it 'uses panel models', ->
      model = panels.model
      expect(model).to.equal Coreon.Models.Panel
