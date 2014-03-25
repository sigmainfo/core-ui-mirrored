#= require spec_helper
#= require lib/panels/panels_manager

describe 'Coreon.Lib.Panels.PanelsManager', ->

  collection = null
  factory = null
  view = null

  beforeEach ->
    view = new Backbone.View
    collection = new Backbone.Collection
    factory = create: ->

  context 'class', ->

    describe '.create()', ->

      instance = null

      beforeEach ->
        sinon.stub Coreon.Collections.Panels, 'instance', ->
          collection

        sinon.stub Coreon.Lib.Panels.PanelFactory, 'instance', ->
          factory

      afterEach ->
        Coreon.Collections.Panels.instance.restore()
        Coreon.Lib.Panels.PanelFactory.instance.restore()

      it 'creates manager instance', ->
        instance = Coreon.Lib.Panels.PanelsManager.create view
        constructor = Coreon.Lib.Panels.PanelsManager
        expect(instance).to.be.an.instanceOf constructor

      it 'passes view to instance', ->
        instance = Coreon.Lib.Panels.PanelsManager.create view
        assigned = instance.view
        expect(assigned).to.equal view

      it 'passes collection to instance', ->
        instance = Coreon.Lib.Panels.PanelsManager.create view
        model = instance.model
        expect(model).to.equal collection

      it 'passes factory to instance', ->
        instance = Coreon.Lib.Panels.PanelsManager.create view
        assigned = instance.factory
        expect(assigned).to.equal factory

  context 'instance', ->

    manager = null

    beforeEach ->
      manager = new Coreon.Lib.Panels.PanelsManager
        model: collection
        view: view
        factory: factory

    describe '#removeAll()', ->

      it 'removes panels', ->
        remove = sinon.spy()
        panel = remove: remove
        model = new Backbone.Model
        model.view = panel
        collection.reset [ model ], silent: yes
        manager.removeAll()
        expect(remove).to.have.been.calledOnce

      it 'clears references to panels', ->
        panel = remove: ->
        model = new Backbone.Model
        model.view = panel
        collection.reset [ model ], silent: yes
        manager.removeAll()
        view = model.view
        expect(view).to.be.null

      it 'resets collection', ->
        model = new Backbone.Model
        model.view = remove: ->
        collection.reset [ model ], silent: yes
        manager.removeAll()
        expect(collection).to.have.lengthOf 0

    describe '#createAll()', ->

      model = null
      panel = null

      beforeEach ->
        model = new Backbone.Model type: 'concepts'
        collection.load = ->
          collection.reset [ model ], silent: yes
        panel = new Backbone.View

      it 'populates collection', ->
        load = sinon.spy()
        collection.load = load
        manager.createAll()
        expect(load).to.have.been.calledOnce

      it 'creates panels', ->
        create = sinon.stub()
        factory.create = create
        create.withArgs('concepts', model).returns panel
        manager.createAll()
        instance = model.view
        expect(instance).to.equal panel

      it 'renders panels', ->
        render = sinon.spy()
        panel.render = render
        create = sinon.stub()
        factory.create = create
        create.returns panel
        manager.createAll()
        expect(render).to.have.been.calledOnce

    describe '#update()', ->

      panel = null
      model = null

      beforeEach ->
        panel = new Backbone.View
        panel.maximize = ->
        panel.widgetize = ->
        model = new Backbone.Model type: 'concepts'
        model.view = panel
        collection.reset [ model ], silent: yes

      it 'is triggered on widget mode change', ->
        update = sinon.spy()
        manager.update = update
        manager.initialize()
        collection.trigger 'change:widget'
        expect(update).to.have.been.calledOnce

      context 'plain', ->

        beforeEach ->
          model.set 'widget', off, silent: yes
          panel.maximize = ->

        it 'maximizes panel', ->
          maximize = sinon.spy()
          panel.maximize = maximize
          manager.update()
          expect(maximize).to.have.been.calledOnce

        it 'appends panel to main area', ->
          view.$el.html '''
            <div id="coreon-main">
            </div>
          '''
          manager.update()
          main = view.$('#coreon-main')[0]
          expect($.contains main, panel.el).to.be.true

      context 'as widget', ->

        beforeEach ->
          model.set 'widget', on, silent: yes
          panel.widgetize = ->

        it 'widgetizes panel', ->
          widgetize = sinon.spy()
          panel.widgetize = widgetize
          manager.update()
          expect(widgetize).to.have.been.calledOnce

        it 'appends panel to widgets column', ->
          view.$el.html '''
            <div id="coreon-widgets">
            </div>
          '''
          manager.update()
          widgets = view.$('#coreon-widgets')[0]
          expect($.contains widgets, panel.el).to.be.true
