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
          sinon.stub Coreon.Views.Panels, 'ConceptsPanel', ->
            panel = new Backbone.View

        afterEach ->
          Coreon.Views.Panels.ConceptsPanel.restore()

        it 'creates panel', ->
          instance = factory.create 'concepts', model
          expect(instance).to.equal panel
          constructor = Coreon.Views.Panels.ConceptsPanel
          expect(constructor).to.have.been.calledWith
            model: app
            panel: model

      context 'conceptMap', ->

        nodes = null
        hits = null

        beforeEach ->
          sinon.stub Coreon.Collections, 'ConceptMapNodes', ->
            nodes = new Backbone.Collection

          sinon.stub Coreon.Collections.Hits, 'collection', ->
            hits ?= new Backbone.Collection

          sinon.stub Coreon.Views.Panels, 'ConceptMapPanel', ->
            panel = new Backbone.View

        afterEach ->
          Coreon.Collections.ConceptMapNodes.restore()
          Coreon.Collections.Hits.collection.restore()
          Coreon.Views.Panels.ConceptMapPanel.restore()

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
          sinon.stub Coreon.Models, 'TermList', ->
            terms = new Backbone.Model

          sinon.stub Coreon.Views.Panels, 'TermListPanel', ->
            panel = new Backbone.View

        afterEach ->
          Coreon.Models.TermList.restore()

        it 'creates panel', ->
          instance = factory.create 'termList', model
          expect(instance).to.equal panel
          constructor = Coreon.Views.Panels.TermListPanel
          expect(constructor).to.have.been.calledWith
            model: terms
            panel: model
