#= require spec_helper
#= require views/panels/concepts/concept_list_view

describe 'Coreon.Views.Panels.Concepts.ConceptListView', ->

  view = null
  selection = null
  app = null

  beforeEach ->
    settings = new Backbone.Model
    app = new Backbone.Model
      repository: new Backbone.Model
    app.sourceLanguage = ->
    app.targetLanguage = ->
    app.lang = -> 'en'
    app.repositorySettings = -> settings
    Coreon.application = app

    sinon.stub Coreon.Views.Concepts, 'ConceptLabelView'
    Coreon.Views.Concepts.ConceptLabelView.returns
      render: -> @
      remove: ->


    sinon.stub Coreon.Views.Concepts, 'ConceptLabelListView'
    Coreon.Views.Concepts.ConceptLabelListView.returns
      render: -> @
      remove: ->

    sinon.stub Coreon.Views.Panels.Concepts.ConceptList, 'TermsView'
    Coreon.Views.Panels.Concepts.ConceptList.TermsView.returns
      render: -> @
      remove: ->

    selection = new Backbone.Collection
    view = new Coreon.Views.Panels.Concepts.ConceptListView
      model: selection

  afterEach ->
    Coreon.Views.Concepts.ConceptLabelView.restore()
    Coreon.Views.Concepts.ConceptLabelListView.restore()
    Coreon.Views.Panels.Concepts.ConceptList.TermsView.restore()
    delete Coreon.application

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'creates container', ->
    el = view.$el
    expect(el).to.have.class 'concept-list'

  describe '#render()', ->

    beforeEach ->
      sinon.stub I18n, 't'

    afterEach ->
      I18n.t.restore()

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    context 'triggers', ->

      render = null

      beforeEach ->
        render = sinon.spy()
        view.render = render
        view.initialize()

      it 'is triggered when source lang changes', ->
        repositorySettings = Coreon.application.repositorySettings()
        repositorySettings.trigger 'change:sourceLanguage'
        expect(render).to.have.been.calledOnce
        expect(render).to.have.been.calledOn view

      it 'is triggered when target lang changes', ->
        repositorySettings = Coreon.application.repositorySettings()
        repositorySettings.trigger 'change:targetLanguage'
        expect(render).to.have.been.calledOnce
        expect(render).to.have.been.calledOn view

    context 'idle', ->

      beforeEach ->
        app.set 'idle', yes, silent: yes

      it 'does not render anything', ->
        view.render()
        el = view.$el
        expect(el).to.be.empty

    context 'edit', ->

      can = null

      beforeEach ->
        sinon.stub Coreon.Helpers, 'can'
        can = Coreon.Helpers.can

      afterEach ->
        Coreon.Helpers.can.restore()

      context 'with maintainer privileges', ->

        beforeEach ->
          can.withArgs('create', Coreon.Models.Concept).returns yes

        it 'renders button for creating a new concept', ->
          app.set
            query: 'März'
            repository: new Backbone.Model id: 'repo-1'
          , silent: yes
          app.lang = -> 'de'
          I18n.t.withArgs('concept.new').returns 'New concept'
          view.render()
          button = view.$('.edit a.create-concept')
          expect(button).to.exist
          expect(button).to.have.attr 'href'
                                    , 'repo-1/concepts/new/terms/de/M%C3%A4rz'
          expect(button).to.have.text 'New concept'

      context 'without maintainer privileges', ->

        beforeEach ->
          can.withArgs('create', Coreon.Models.Concept).returns no

        it 'does not render edit buttons', ->
          view.render()
          button = view.$('.edit a')
          expect(button).to.not.exist

    context 'empty selection', ->

      beforeEach ->
        selection.reset [], silent: yes

      it 'renders info', ->
        app.set 'query', 'foo', silent: yes
        info = 'No concepts found for "foo"'
        I18n.t.withArgs('concepts.list.empty', query: 'foo').returns info
        view.render()
        tr = view.$('tr')
        expect(tr).to.have.lengthOf 1
        td = tr.find('td')
        expect(td).to.have.lengthOf 1
        expect(td).to.have.class 'empty-list'
        expect(td).to.have.text info

    context 'with selection', ->

      concept = null

      createConcept = ->
        concept = new Backbone.Model
        concept.broader = -> []
        concept.definition = -> ''
        concept

      beforeEach ->
        concept = createConcept()
        selection.reset [concept], silent: yes

      it 'renders one row per concept', ->
        _(2).times ->
          concept = createConcept()
          selection.add concept, silent: yes
        view.render()
        rows = view.$('table tbody tr.concept-list-item')
        expect(rows).to.have.lengthOf 3

      it 'inserts concept label', ->
        label = new Backbone.View
        render = sinon.spy()
        label.render = render
        constructor = Coreon.Views.Concepts.ConceptLabelView
        constructor.withArgs(model: concept).returns label
        view.render()
        expect(render).to.have.been.calledOnce
        td = view.$('tr.label td').get(0)
        el = label.el
        expect($.contains td, el).to.be.true

      it 'renders label for superconcepts', ->
        I18n.t.withArgs('concepts.list.headers.broader').returns 'Broader'
        view.render()
        cell = view.$('tr.broader th')
        expect(cell).to.exist
        expect(cell).to.have.text 'Broader'

      it 'inserts list of labels for superconcepts', ->
        broader = [ new Backbone.Model ]
        concept.broader = -> broader
        labelList = new Backbone.View
        render = sinon.spy()
        labelList.render = render
        constructor = Coreon.Views.Concepts.ConceptLabelListView
        constructor.withArgs(models: broader).returns labelList
        view.render()
        expect(render).to.have.been.calledOnce
        td = view.$('tr.broader td').get(0)
        el = labelList.el
        expect($.contains td, el).to.be.true

      it 'renders label for definition', ->
        I18n.t.withArgs('concepts.list.headers.definition').returns 'Definition'
        concept.definition = -> 'Eine Rose ist eine Rose ist eine Rose'
        view.render()
        cell = view.$('tr.definition th')
        expect(cell).to.exist
        expect(cell).to.have.text 'Definition'

      it 'renders definition', ->
        concept.definition = -> 'Eine Rose ist eine Rose ist eine Rose'
        view.render()
        cell = view.$('tr.definition td')
        expect(cell).to.exist
        expect(cell).to.have.text 'Eine Rose ist eine Rose ist eine Rose'

      it 'skips rendering row for definition when missing', ->
        concept.definition = -> null
        view.render()
        row = view.$('tr.definition')
        expect(row).to.not.exist

      it 'inserts terms', ->
        terms = new Backbone.View tagName: 'tbody'
        render = sinon.spy()
        terms.render = render
        constructor = Coreon.Views.Panels.Concepts.ConceptList.TermsView
        constructor.withArgs(model: concept).returns terms
        view.render()
        expect(render).to.have.been.calledOnce
        table = view.$('tr.concept-list-item table').get(0)
        el = terms.el
        expect($.contains table, el).to.be.true

  # beforeEach ->
  #   settings = new Backbone.Model
  #   Coreon.application =
  #     sourceLang: -> null
  #     targetLang: -> null
  #     repositorySettings: -> settings
  #   sinon.stub Coreon.Views.Concepts, 'ConceptLabelView'
  #   Coreon.Views.Concepts.ConceptLabelView.returns
  #     render: -> @
  #     remove: ->
  #   @view = new Coreon.Views.Panels.Concepts.ConceptListView
  #     model: new Backbone.Model
  #       hits: []
  #       done: no
  #
  # afterEach ->
  #   Coreon.Views.Concepts.ConceptLabelView.restore()
  #   delete Coreon.application
  #
  #
  # describe '#render()', ->
  #
  #     context 'with hits', ->
  #
  #       beforeEach ->
  #         @results = ['ball', 'ballistics', '8-ball'].map (label) ->
  #           concept = new Backbone.Model label: label
  #           concept.broader = -> []
  #           concept.definition = -> null
  #           concept.termsByLang = -> {}
  #           concept
  #
  #
  #       context 'terms', ->
  #
  #         beforeEach ->
  #           concept = @results[0]
  #           concept.termsByLang = ->
  #             en: [
  #               new Backbone.Model( value: 'gun' )
  #               new Backbone.Model( value: 'balloon' )
  #             ]
  #             de: [
  #               new Backbone.Model( value: 'Schuh' )
  #             ]
  #
  #         it 'renders English terms by default', ->
  #           Coreon.application.sourceLang = -> null
  #           Coreon.application.targetLang = -> null
  #           @view.render()
  #           row = @view.$ 'tr.concept-list-item:first'
  #           expect( row ).to.have('tr.lang')
  #           expect( row.find 'tr.lang' ).to.have.lengthOf 1
  #           expect( row.find 'tr.lang th' ).to.have.text 'en'
  #           terms = row.find('tr.lang td').text()
  #           expect( terms ).to.match /^balloon\s+|\s+gun$/
  #
  #         it 'renders terms of source lang', ->
  #           Coreon.application.sourceLang = -> 'de'
  #           Coreon.application.targetLang = -> null
  #           @view.render()
  #           row = @view.$ 'tr.concept-list-item:first'
  #           expect( row ).to.have('tr.lang')
  #           expect( row.find 'tr.lang' ).to.have.lengthOf 1
  #           expect( row.find 'tr.lang th' ).to.have.text 'de'
  #           expect( row.find('tr.lang td').text() ).to.equal 'Schuh'
  #
  #         it 'renders terms of target lang', ->
  #           Coreon.application.sourceLang = -> 'en'
  #           Coreon.application.targetLang = -> 'de'
  #           @view.render()
  #           row = @view.$ 'tr.concept-list-item:first'
  #           expect( row ).to.have('tr.lang')
  #           expect( row.find 'tr.lang' ).to.have.lengthOf 2
  #           expect( row.find 'tr.lang:first th' ).to.have.text 'en'
  #           expect( row.find 'tr.lang:last th' ).to.have.text 'de'
  #           terms =  row.find('tr.lang:last td').text()
  #           expect( terms ).to.equal 'Schuh'
  #
  #         it 'renders empty cell if no terms are given', ->
  #           Coreon.application.sourceLang = -> 'hu'
  #           Coreon.application.targetLang = -> null
  #           @view.render()
  #           row = @view.$ 'tr.concept-list-item:first'
  #           expect( row ).to.have('tr.lang')
  #           expect( row.find 'tr.lang' ).to.have.lengthOf 1
  #           expect( row.find 'tr.lang:first th' ).to.have.text 'hu'
  #           expect( row.find 'tr.lang:first td' ).to.have.text ''
