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
        expect(types).to.eql ['concepts', 'clipboard', 'conceptMap', 'termList']

      it 'widgetizes all panes execept the first one', ->
        widgetized = instance.pluck 'widget'
        expect(widgetized).to.eql [off, on, on, on]

      it 'sets clipboard height', ->
        clipboard = instance.findWhere type: 'clipboard'
        height = clipboard.get('height')
        expect(height).to.equal 80

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

      it 'updates width of other panels', ->
        other = new Backbone.Model widget: on
        panels.reset [widget, other], silent: yes
        panels.trigger 'change:width', widget, 123
        width = other.get('width')
        expect(width).to.equal 123

      it 'does not update widths from maximized panel', ->
        widget.set 'width', 200, silent: yes
        panel = new Backbone.Model widget: off
        panels.reset [widget, panel], silent: yes
        panels.trigger 'change:width', panel, 123
        width = widget.get('width')
        expect(width).to.equal 200

    describe '#cyclePanels()', ->

      panel = null

      beforeEach ->
        panel = new Backbone.Model widget: off

      it 'is triggered by changes on widget mode', ->
        cycle = sinon.spy()
        panels.cyclePanels = cycle
        panels.initialize()
        panels.trigger 'change:widget', panel, off
        expect(cycle).to.have.been.calledOnce
        expect(cycle).to.have.been.calledOn panels
        expect(cycle).to.have.been.calledWith panel, off

      it 'makes all other panels to widgets', ->
        other = new Backbone.Model widget: off
        panels.reset [other, panel], silent: yes
        panels.cyclePanels panel, off
        widgetized = other.get('widget')
        expect(widgetized).to.be.true

      it 'keeps changed panel maximized', ->
        other = new Backbone.Model widget: off
        panels.reset [other, panel], silent: yes
        panels.cyclePanels panel, off
        widgetized = panel.get('widget')
        expect(widgetized).to.be.false
