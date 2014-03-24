#= require spec_helper
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

    describe '#syncWidgetWidths()', ->

      widget = null

      beforeEach ->
        widget = new Backbone.Model widget: on

      it 'is triggered by changes of width', ->
        sync = sinon.spy()
        panels.syncWidgetWidths = sync
        panels.initialize()
        panels.trigger 'change:width', widget, 123
        expect(sync).to.have.been.calledOnce
        expect(sync).to.have.been.calledOn panels
        expect(sync).to.have.been.calledWith widget, 123

      it 'updates width of other widgets', ->
        other = new Backbone.Model widget: on
        panels.reset [widget, other], silent: yes
        panels.trigger 'change:width', widget, 123
        width = other.get('width')
        expect(width).to.equal 123

      it 'does not update width of maximized panels', ->
        other = new Backbone.Model widget: off, width: 200
        panels.reset [widget, other], silent: yes
        panels.trigger 'change:width', widget, 123
        width = other.get('width')
        expect(width).to.equal 200

      it 'does not update widths from maximized panel', ->
        widget.set 'width', 200, silent: yes
        panel = new Backbone.Model widget: off
        panels.reset [widget, panel], silent: yes
        panels.trigger 'change:width', panel, 123
        width = widget.get('width')
        expect(width).to.equal 200
