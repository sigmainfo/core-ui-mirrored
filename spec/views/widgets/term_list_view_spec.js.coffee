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
      model: new Backbone.Collection

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

    it 'is triggered on language changes', ->
      @view.render = sinon.spy()
      @view.initialize()
      Coreon.application.repositorySettings().trigger 'change:sourceLanguage'
      expect( @view.render ).to.have.been.calledOnce
      expect( @view.render ).to.have.been.calledOn @view

    it 'triggered on selection changes', ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger 'reset'
      expect( @view.render ).to.have.been.calledOnce
      expect( @view.render ).to.have.been.calledOn @view

    context 'no source language', ->

      beforeEach ->
        Coreon.application.repositorySettings.withArgs('sourceLanguage').returns 'none'

      it 'renders info', ->
        I18n.t.withArgs('widgets.term_list.empty').returns 'No language selected'
        @view.render()
        expect( @view.$el ).to.have 'tbody tr.empty'
        expect( @view.$('tr.empty td') ).to.have.text 'No language selected'

    context 'unknown source language', ->

      beforeEach ->
        Coreon.application.repositorySettings.withArgs('sourceLanguage').returns {}

      it 'renders info', ->
        I18n.t.withArgs('widgets.term_list.empty').returns 'No language selected'
        @view.render()
        expect( @view.$el ).to.have 'tbody tr.empty'
        expect( @view.$('tr.empty td') ).to.have.text 'No language selected'

    context 'with source language', ->

      beforeEach ->
        Coreon.application.repositorySettings.withArgs('sourceLanguage').returns 'en'
        sinon.stub Coreon.Models, 'Concept'
        concept = new Backbone.Model
        concept.path = -> '/repo/concepts/123'
        Coreon.Models.Concept.returns concept

      afterEach ->
        Coreon.Models.Concept.restore()

      it 'does not render info', ->
        I18n.t.withArgs('widgets.term_list.empty').returns 'No language selected'
        @view.$('ul').append '<li class="empty">No language selected</li>'
        @view.render()
        expect( @view.$el ).to.not.have '.empty'
        expect( @view.$el ).to.not.have.text 'No language selected'

      it 'renders terms', ->
        @view.model.reset [
         { id: 'term-1' , lang: 'en'  , value: 'billiards'        , concept_id: '345fgh' }
         { id: 'term-2' , lang: 'en'  , value: 'cue'              , concept_id: 'jhg321' }
         { id: 'term-3' , lang: 'en'  , value: 'pocket billiards' , concept_id: '4567ha' }
        ], silent: yes
        @view.render()
        expect( @view.$ 'tbody' ).to.have 'tr.term td.source'
        expect( @view.$ 'tbody tr.term td.source' ).to.have.property 'length', 3
        expect( @view.$('tbody tr.term:nth-child(1) td.source').text() ).to.contain 'billiards'
        expect( @view.$('tbody tr.term:nth-child(2) td.source').text() ).to.contain 'cue'
        expect( @view.$('tbody tr.term:nth-child(3) td.source').text() ).to.contain 'pocket billiards'

      it 'renders link to concept', ->
        @view.model.reset [
         { id: 'fgh456', lang: 'en', value: 'cue', concept_id: 'concept-123' }
        ], silent: yes
        concept = new Backbone.Model
        concept.path = -> '/my-repository/concepts/concept-123'
        Coreon.Models.Concept.withArgs( id: 'concept-123' ).returns concept
        @view.render()
        link = @view.$ 'tbody td.source a'
        expect( link ).to.exist
        expect( link ).to.have.attr 'href', '/my-repository/concepts/concept-123'
        expect( link ).to.have.text 'cue'
