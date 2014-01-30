#= require spec_helper
#= require views/panels/concepts/concept_list_view

describe 'Coreon.Views.Panels.Concepts.ConceptListView', ->

  beforeEach ->
    settings = new Backbone.Model
    Coreon.application =
      sourceLang: -> null
      targetLang: -> null
      repositorySettings: -> settings
    sinon.stub Coreon.Views.Concepts, 'ConceptLabelView'
    Coreon.Views.Concepts.ConceptLabelView.returns
      render: -> @
      remove: ->
    @view = new Coreon.Views.Panels.Concepts.ConceptListView
      model: new Backbone.Model
        hits: []
        done: no

  afterEach ->
    Coreon.Views.Concepts.ConceptLabelView.restore()
    delete Coreon.application

  it 'is a Backbone view', ->
    expect( @view ).to.be.an.instanceof Backbone.View

  it 'creates container', ->
    expect( @view.$el ).to.match 'div.concept-list'

  describe '#render()', ->

    beforeEach ->
      sinon.stub I18n, 't'
      sinon.stub Coreon.Helpers, 'can'
      sinon.stub Coreon.Helpers, 'repositoryPath'

    afterEach ->
      I18n.t.restore()
      Coreon.Helpers.can.restore()
      Coreon.Helpers.repositoryPath.restore()

    it 'can be chained', ->
      expect( @view.render() ).to.equal @view

    it 'is triggered when done', ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger 'change:done'
      expect( @view.render ).to.have.been.calledOnce
      expect( @view.render ).to.have.been.calledOn @view

    it 'is triggered when source lang changes', ->
      @view.render = sinon.spy()
      @view.initialize()
      Coreon.application.repositorySettings().trigger 'change:sourceLanguage'
      expect( @view.render ).to.have.been.calledOnce
      expect( @view.render ).to.have.been.calledOn @view

    it 'is triggered when target lang changes', ->
      @view.render = sinon.spy()
      @view.initialize()
      Coreon.application.repositorySettings().trigger 'change:targetLanguage'
      expect( @view.render ).to.have.been.calledOnce
      expect( @view.render ).to.have.been.calledOn @view

    context 'searching', ->

      beforeEach ->
        @view.model.set 'done', no, silent: yes

      it 'clears table', ->
        @view.$el.append '<tr>'
        @view.render()
        expect( @view.$el ).to.be.empty

    context 'done', ->

      beforeEach ->
        @results = []
        @view.model.results = => @results
        @view.model.set 'done', yes, silent: yes

      context 'without any hits', ->

        beforeEach ->
          @results = []

        it 'renders info message when done', ->
          I18n.t.withArgs('concepts.list.empty', query: 'ball')
            .returns 'No concepts found for "ball"'
          @view.model.set 'query', 'ball', silent: yes
          @view.render()
          expect( @view.$el ).to.have 'table tbody tr td.empty-list'
          expect( @view.$ 'td.empty-list' ).to.have.text 'No concepts found for "ball"'

        it 'renders title', ->
          I18n.t.withArgs('concepts.list.title').returns 'Concepts'
          @view.render()
          expect( @view.$el ).to.have '> h3'
          expect( @view.$ '> h3' ).to.have.text 'Concepts'

      context 'with hits', ->

        beforeEach ->
          @results = ['ball', 'ballistics', '8-ball'].map (label) ->
            concept = new Backbone.Model label: label
            concept.broader = -> []
            concept.definition = -> null
            concept.termsByLang = -> {}
            concept

        it 'renders title', ->
          I18n.t.withArgs('concepts.list.title').returns 'Concepts'
          @view.render()
          expect( @view.$el ).to.have '> h3'
          expect( @view.$ '> h3' ).to.have.text 'Concepts'

        it 'renders row for each hit', ->
          @view.render()
          expect( @view.$el ).to.have 'table tbody tr.concept-list-item'
          expect( @view.$ '.concept-list-item' ).to.have.lengthOf 3

        it 'renders label', ->
          concept = @results[0]
          label = new Backbone.View
          Coreon.Views.Concepts.ConceptLabelView
            .withArgs(model: concept).returns label
          @view.render()
          expect( @view.$el ).to.not.have '.concept-list-item table tr.label th'
          expect( @view.$el ).to.have '.concept-list-item table tr.label td'
          td = @view.$('tr.label:first td')
          expect( $.contains td.get(0), label.el ).to.be.true

        it 'renders labels for broader concepts', ->
          I18n.t.withArgs('concepts.list.headers.broader').returns 'Broader'
          concept = @results[0]
          parent1 = new Backbone.Model label: 'parent1'
          parent2 = new Backbone.Model label: 'parent2'
          concept.broader = -> [ parent1, parent2 ]
          label1 = new Backbone.View
          Coreon.Views.Concepts.ConceptLabelView
            .withArgs(model: parent1).returns label1
          label2 = new Backbone.View
          Coreon.Views.Concepts.ConceptLabelView
            .withArgs(model: parent2).returns label2
          @view.render()
          expect( @view.$el ).to.have '.concept-list-item table tr.broader th'
          expect( @view.$ 'tr.broader:first th' ).to.have.text 'Broader'
          expect( @view.$el ).to.have '.concept-list-item table tr.broader td'
          td = @view.$('tr.broader:first td')
          expect( $.contains td.get(0), label1.el ).to.be.true
          expect( $.contains td.get(0), label2.el ).to.be.true

        it 'sorts broader concepts alphabetically', ->
          concept = @results[0]
          parent1 = new Backbone.Model label: 'mouse'
          parent2 = new Backbone.Model label: 'apple'
          parent3 = new Backbone.Model label: 'young'
          concept.broader = -> [ parent1, parent2, parent3 ]
          label1 = new Backbone.View
          Coreon.Views.Concepts.ConceptLabelView
            .withArgs(model: parent1).returns label1
          label2 = new Backbone.View
          Coreon.Views.Concepts.ConceptLabelView
            .withArgs(model: parent2).returns label2
          label3 = new Backbone.View
          Coreon.Views.Concepts.ConceptLabelView
            .withArgs(model: parent3).returns label3
          @view.render()
          td = @view.$('tr.broader:first td')
          expect( td.find('*:nth-child(1)').get 0 ).to.equal label2.el
          expect( td.find('*:nth-child(2)').get 0 ).to.equal label1.el
          expect( td.find('*:nth-child(3)').get 0 ).to.equal label3.el

        it 'resorts broader concepts on label change', ->
          concept = @results[0]
          parent1 = new Backbone.Model label: 'mouse'
          parent2 = new Backbone.Model label: 'apple'
          parent3 = new Backbone.Model label: 'young'
          concept.broader = -> [ parent1, parent2, parent3 ]
          label1 = new Backbone.View
          Coreon.Views.Concepts.ConceptLabelView
            .withArgs(model: parent1).returns label1
          label2 = new Backbone.View
          Coreon.Views.Concepts.ConceptLabelView
            .withArgs(model: parent2).returns label2
          label3 = new Backbone.View
          Coreon.Views.Concepts.ConceptLabelView
            .withArgs(model: parent3).returns label3
          @view.render()
          parent3.set 'label', 'banana'
          td = @view.$('tr.broader:first td')
          expect( td.find('*:nth-child(1)').get 0 ).to.equal label2.el
          expect( td.find('*:nth-child(2)').get 0 ).to.equal label3.el
          expect( td.find('*:nth-child(3)').get 0 ).to.equal label1.el

        it 'renders definition', ->
          I18n.t.withArgs('concepts.list.headers.definition').returns 'Definition'
          concept = @results[0]
          concept.definition = -> 'Eine Rose'
          @view.render()
          expect( @view.$el ).to.have '.concept-list-item table tr.definition th'
          expect( @view.$ 'tr.definition:first th' ).to.have.text 'Definition'
          expect( @view.$ 'tr.definition:first td' ).to.have.text 'Eine Rose'

        it 'skips definition when not given', ->
          I18n.t.withArgs('concepts.list.headers.definition').returns 'Definition'
          concept = @results[0]
          concept.definition = -> null
          @view.render()
          expect( @view.$el ).to.not.have '.concept-list-item table tr.definition'

        context 'terms', ->

          beforeEach ->
            concept = @results[0]
            concept.termsByLang = ->
              en: [
                new Backbone.Model( value: 'gun' )
                new Backbone.Model( value: 'balloon' )
              ]
              de: [
                new Backbone.Model( value: 'Schuh' )
              ]

          it 'renders English terms by default', ->
            Coreon.application.sourceLang = -> null
            Coreon.application.targetLang = -> null
            @view.render()
            row = @view.$ 'tr.concept-list-item:first'
            expect( row ).to.have('tr.lang')
            expect( row.find 'tr.lang' ).to.have.lengthOf 1
            expect( row.find 'tr.lang th' ).to.have.text 'en'
            terms = row.find('tr.lang td').text()
            expect( terms ).to.match /^balloon\s+|\s+gun$/

          it 'renders terms of source lang', ->
            Coreon.application.sourceLang = -> 'de'
            Coreon.application.targetLang = -> null
            @view.render()
            row = @view.$ 'tr.concept-list-item:first'
            expect( row ).to.have('tr.lang')
            expect( row.find 'tr.lang' ).to.have.lengthOf 1
            expect( row.find 'tr.lang th' ).to.have.text 'de'
            expect( row.find('tr.lang td').text() ).to.equal 'Schuh'

          it 'renders terms of target lang', ->
            Coreon.application.sourceLang = -> 'en'
            Coreon.application.targetLang = -> 'de'
            @view.render()
            row = @view.$ 'tr.concept-list-item:first'
            expect( row ).to.have('tr.lang')
            expect( row.find 'tr.lang' ).to.have.lengthOf 2
            expect( row.find 'tr.lang:first th' ).to.have.text 'en'
            expect( row.find 'tr.lang:last th' ).to.have.text 'de'
            terms =  row.find('tr.lang:last td').text()
            expect( terms ).to.equal 'Schuh'

          it 'renders empty cell if no terms are given', ->
            Coreon.application.sourceLang = -> 'hu'
            Coreon.application.targetLang = -> null
            @view.render()
            row = @view.$ 'tr.concept-list-item:first'
            expect( row ).to.have('tr.lang')
            expect( row.find 'tr.lang' ).to.have.lengthOf 1
            expect( row.find 'tr.lang:first th' ).to.have.text 'hu'
            expect( row.find 'tr.lang:first td' ).to.have.text ''

      context 'with edit privileges', ->

        beforeEach ->
          Coreon.Helpers.can.returns true

        it 'renders link to new concept from search', ->
          Coreon.application.sourceLang = -> 'de'
          I18n.t.withArgs('concept.new').returns 'New Concept'
          @view.model.set 'query', 'billiard ball', silent: yes
          Coreon.Helpers.repositoryPath.withArgs('concepts/new/terms/de/billiard%20ball')
            .returns '/my-repo123/concepts/new/terms/de/billiard%20ball'
          @view.render()
          expect( @view.$el ).to.have '.edit a.create-concept'
          a = @view.$ '.edit a.create-concept'
          expect( a ).to.have.text 'New Concept'
          expect( a ).to.have.attr 'href', '/my-repo123/concepts/new/terms/de/billiard%20ball'

      context 'without edit privileges', ->

        beforeEach ->
          Coreon.Helpers.can.returns false

        it 'renders no create concept button', ->
          @view.render()
          expect( @view.$el ).to.not.have 'a.create-concept'

