#= require spec_helper
#= require views/concepts/concept_list_view

describe 'Coreon.Views.Concepts.ConceptListView', ->

  beforeEach ->
    sinon.stub Coreon.Views.Concepts, 'ConceptLabelView'
    Coreon.Views.Concepts.ConceptLabelView.returns
      render: -> @
      remove: ->
    @view = new Coreon.Views.Concepts.ConceptListView
      model: new Backbone.Model
        hits: []
        done: no

  afterEach ->
    Coreon.Views.Concepts.ConceptLabelView.restore()

  it 'is a Backbone view', ->
    expect( @view ).to.be.an.instanceof Backbone.View

  it 'creates container', ->
    expect( @view.$el ).to.match 'div.concept-list'

  describe '#render()', ->

    beforeEach ->
      sinon.stub I18n, 't'

    afterEach ->
      I18n.t.restore()

    it 'can be chained', ->
      expect( @view.render() ).to.equal @view

    it 'is triggered when done', ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger 'change:done'
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
          I18n.t.withArgs('concepts.list.headers.label').returns 'Label'
          concept = @results[0]
          label = new Backbone.View
          Coreon.Views.Concepts.ConceptLabelView
            .withArgs(model: concept).returns label
          @view.render()
          expect( @view.$el ).to.have '.concept-list-item table tr.label th'
          expect( @view.$ 'tr.label:first th' ).to.have.text 'Label'
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
