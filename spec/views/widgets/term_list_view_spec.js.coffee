#= require spec_helper
#= require views/widgets/term_list_view

describe 'Coreon.Views.Widgets.TermListView', ->

  beforeEach ->
    sinon.stub I18n, "t"
    repository = new Backbone.Model
    settings = new Backbone.Model
    Coreon.application =
      repositorySettings: sinon.stub().returns settings
      repository: -> repository
    @view = new Coreon.Views.Widgets.TermListView
      model: new Backbone.Model

  afterEach ->
    I18n.t.restore()

  it 'is a Backbone view', ->
    expect( @view ).to.be.an.instanceof Backbone.View

  it 'creates container', ->
    expect( @view.$el ).to.have.id 'coreon-term-list'
    expect( @view.$el ).to.have.class 'widget'

  describe '#initialize()', ->

    it 'renders markup', ->
      I18n.t.withArgs('widgets.term_list.title').returns 'Term List'
      @view.initialize()
      expect( @view.$el ).to.have '.titlebar h4'
      expect( @view.$ '.titlebar h4' ).to.have.text 'Term List'

    it 'renders resize handler', ->
      expect( @view.$el ).to.have  '.ui-resizable-s'

  describe '#render()', ->

    it 'can be chained', ->
      expect( @view.render() ).to.equal @view

    it 'is triggered on model changes', ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger 'change'
      expect( @view.render ).to.have.been.calledOnce
      expect( @view.render ).to.have.been.calledOn @view

    context 'no source language', ->

      beforeEach ->
        @view.model.set 'source', null, silent: yes

      it 'renders info', ->
        I18n.t.withArgs('widgets.term_list.empty').returns 'No language selected'
        @view.render()
        expect( @view.$el ).to.have 'tbody tr.empty'
        expect( @view.$('tr.empty td') ).to.have.text 'No language selected'

    context 'with selected source language', ->

      beforeEach ->
        @view.model.set 'source', 'en', silent: yes
        @terms = new Backbone.Collection
        @view.model.terms = => @terms

      it 'does not render info', ->
        I18n.t.withArgs('widgets.term_list.empty').returns 'No language selected'
        @view.$('ul').append '<li class="empty">No language selected</li>'
        @view.render()
        expect( @view.$el ).to.not.have '.empty'
        expect( @view.$el ).to.not.have.text 'No language selected'

      it 'renders terms', ->
        @terms.reset ['billiards', 'cue', 'pocket billiards'].map ( value ) ->
          term = new Backbone.Model value: value
          term.conceptPath = -> ''
          term
        , silent: yes
        @view.render()
        expect( @view.$ 'tbody' ).to.have 'tr.term td.source'
        expect( @view.$ 'tbody tr.term td.source' ).to.have.property 'length', 3
        expect( @view.$('tbody tr.term:nth-child(1) td.source').text() ).to.contain 'billiards'
        expect( @view.$('tbody tr.term:nth-child(2) td.source').text() ).to.contain 'cue'
        expect( @view.$('tbody tr.term:nth-child(3) td.source').text() ).to.contain 'pocket billiards'

      it 'renders link to concept', ->
        term = new Backbone.Model value: 'billiards'
        term.conceptPath = -> '/my-repository/concepts/concept-123'
        @terms.reset [ term ], silent: yes
        @view.render()
        link = @view.$ 'tbody td.source a'
        expect( link ).to.exist
        expect( link ).to.have.attr 'href', '/my-repository/concepts/concept-123'
        expect( link ).to.have.text 'billiards'
