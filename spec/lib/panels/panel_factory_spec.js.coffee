#= require spec_helper
#= require lib/panels/panel_factory

describe 'Coreon.Lib.Panels.PanelFactory', ->

  app = null

  beforeEach ->
    app = new Backbone.Model

  context 'class', ->

    instance = null

    describe '.instance()', ->

      beforeEach ->
        Coreon.application = app
        instance = Coreon.Lib.Panels.PanelFactory.instance()

      afterEach ->
        delete Coreon.Lib.Panels.PanelFactory._instance
        delete Coreon.application

      it 'creates instance', ->
        constructor = Coreon.Lib.Panels.PanelFactory
        expect(instance).to.be.an.instanceOf constructor

      it 'creates instance only once', ->
        result = Coreon.Lib.Panels.PanelFactory.instance()
        expect(result).to.equal instance

      it 'passes app to instance', ->
        assigned = instance.app
        expect(assigned).to.equal app

  context 'instance', ->

    factory = null
    app = null

    beforeEach ->
      app = new Backbone.Model
      factory = new Coreon.Lib.Panels.PanelFactory app

    describe '#constructor()', ->

      it 'assigns app', ->
        assigned = factory.app
        expect(assigned).to.equal app

    describe '#create()', ->

      panel = null
      model = null

      beforeEach ->
        model = new Backbone.Model

      context 'concepts', ->

        beforeEach ->
          @stub Coreon.Views.Panels, 'ConceptsPanel', ->
            panel = new Backbone.View

        it 'creates panel', ->
          instance = factory.create 'concepts', model
          expect(instance).to.equal panel
          constructor = Coreon.Views.Panels.ConceptsPanel
          expect(constructor).to.have.been.calledWith
            model: app
            panel: model

      context 'clipbaord', ->

        beforeEach ->
          @stub Coreon.Views.Panels, 'ClipboardPanel', ->
            panel = new Backbone.View
#
        it 'creates panel', ->
          instance = factory.create 'clipboard', model
          expect(instance).to.equal panel
          constructor = Coreon.Views.Panels.ClipboardPanel
          expect(constructor).to.have.been.calledWith
            panel: model

      context 'conceptMap', ->

        nodes = null
        hits = null

        beforeEach ->
          @stub Coreon.Collections, 'ConceptMapNodes', ->
            nodes = new Backbone.Collection

          @stub Coreon.Collections.Hits, 'collection', ->
            hits ?= new Backbone.Collection

          @stub Coreon.Views.Panels, 'ConceptMapPanel', ->
            panel = new Backbone.View

        it 'creates panel', ->
          instance = factory.create 'conceptMap', model
          expect(instance).to.equal panel
          constructor = Coreon.Views.Panels.ConceptMapPanel
          expect(constructor).to.have.been.calledWith
            model: nodes
            hits: hits
            panel: model

      context 'termList', ->

        terms = null

        beforeEach ->
          @stub Coreon.Models, 'TermList', ->
            terms = new Backbone.Model

          @stub Coreon.Views.Panels, 'TermListPanel', ->
            panel = new Backbone.View

        it 'creates panel', ->
          instance = factory.create 'termList', model
          expect(instance).to.equal panel
          constructor = Coreon.Views.Panels.TermListPanel
          expect(constructor).to.have.been.calledWith
            model: terms
            panel: model
