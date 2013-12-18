#= require spec_helper
#= require views/concepts/concept_list_view

describe 'Coreon.Views.Concepts.ConceptListView', ->

  beforeEach ->
    sinon.stub Coreon.Views.Concepts, 'ConceptLabelView'
    Coreon.Views.Concepts.ConceptLabelView.returns render: -> @
    @view = new Coreon.Views.Concepts.ConceptListView
      model: new Backbone.Model
        hits: []
        done: no

  afterEach ->
    Coreon.Views.Concepts.ConceptLabelView.restore()

  it 'is a Backbone view', ->
    expect( @view ).to.be.an.instanceof Backbone.View

  it 'creates container', ->
    expect( @view.$el ).to.match 'table.concept-list'

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
          expect( @view.$el ).to.have 'tbody tr td.empty-list'
          expect( @view.$ 'td.empty-list' ).to.have.text 'No concepts found for "ball"'

      context 'with hits', ->

        beforeEach ->
          @results = [
            { result: new Backbone.Model label: 'ball' }
            { result: new Backbone.Model label: 'ballistics' }
            { result: new Backbone.Model label: '8-ball' }
          ]

        it 'renders row for each hit', ->
          @view.render()
          expect( @view.$el ).to.have 'tbody tr.concept-list-item'
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
