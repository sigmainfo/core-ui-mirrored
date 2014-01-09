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
    model = new Backbone.Model
    model.hits = new Backbone.Collection
    model.terms = new Backbone.Collection
    model.hasNext = -> no
    @view = new Coreon.Views.Widgets.TermListView
      model: model

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

    it 'renders toggle button', ->
      I18n.t.withArgs('widgets.term_list.toggle_scope').returns 'Toggle scope'
      @view.initialize()
      toggle = @view.$('.toggle-scope')
      expect( toggle ).to.exist
      expect( toggle ).to.have.attr 'href', 'javascript:void(0)'
      expect( toggle ).to.have.text 'Toggle scope'
      expect( toggle ).to.have.attr 'title', 'Toggle scope'

  describe '#render()', ->

    it 'can be chained', ->
      expect( @view.render() ).to.equal @view

    it 'is triggered on model updates', ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger 'reset'
      expect( @view.render ).to.have.been.calledOnce
      expect( @view.render ).to.have.been.calledOn @view

    it 'resets scroll position', ->
      $( '#konacha' ).append @view.$el
      inner = @view.$ 'tbody'
      inner.height 200
      outer = @view.$ 'table'
      outer.height 100
      outer.scrollTop 25
      @view.render()
      expect( outer.scrollTop() ).to.equal 0

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

      it 'does not render info', ->
        I18n.t.withArgs('widgets.term_list.empty').returns 'No language selected'
        @view.$('ul').append '<li class="empty">No language selected</li>'
        @view.render()
        expect( @view.$el ).to.not.have '.empty'
        expect( @view.$el ).to.not.have.text 'No language selected'

      it 'renders terms', ->
        @view.model.terms.reset ['billiards', 'cue', 'pocket billiards'].map ( value ) ->
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
        @view.model.terms.reset [ term ], silent: yes
        @view.render()
        link = @view.$ 'tbody td.source a'
        expect( link ).to.exist
        expect( link ).to.have.attr 'href', '/my-repository/concepts/concept-123'
        expect( link ).to.have.text 'billiards'

      it 'clasifies hits', ->
        @view.model.terms.reset ['billiards', 'cue', 'pocket billiards'].map ( value, index ) =>
          term = new Backbone.Model value: value
          term.conceptPath = -> ''
          term
        , silent: yes
        @view.model.hits.reset [ @view.model.terms.at(1) ], silent: yes
        @view.render()
        expect( @view.$ 'tbody' ).to.have 'tr.term.hit'
        expect( @view.$ 'tbody tr.term.hit' ).to.have.property 'length', 1
        expect( @view.$('tbody tr.term:nth-child(1)') ).to.not.have.class 'hit'
        expect( @view.$('tbody tr.term:nth-child(2)') ).to.have.class 'hit'
        expect( @view.$('tbody tr.term:nth-child(3)') ).to.not.have.class 'hit'

  describe '#topUp()', ->

    it 'is triggered on scroll', ->
      @view.topUp = sinon.spy()
      @view.delegateEvents()
      @view.$( 'tbody' ).scroll()
      expect( @view.topUp ).to.have.been.calledOnce
      expect( @view.topUp ).to.have.been.calledOn @view

    context 'close to tail', ->

      beforeEach ->
        @view.$('table').height 100
        @view.$('tbody').height 120
        @view.model.next = sinon.spy =>
          @deferred = $.Deferred()
          @deferred.promise()

      context 'not yet completely loaded', ->

        beforeEach ->
          @view.model.hasNext = -> yes

        it 'calls next on model', ->
          @view.topUp()
          expect( @view.model.next ).to.have.been.calledOnce

        context 'loading', ->

          beforeEach ->
            @view.model.set 'loadingNext', on, silent: yes

          it 'does not call next on model', ->
            @view.topUp()
            expect( @view.model.next ).to.not.have.been.called



      context 'completely loaded', ->

        beforeEach ->
          @view.model.hasNext = -> no

        it 'does not call next on model', ->
          @view.topUp()
          expect( @view.model.next ).to.not.have.been.called

    context 'far away from tail', ->

      beforeEach ->
        @view.$('table').height 100
        @view.$('tbody').height 300

      it 'does not call next on model', ->
        @view.model.next = sinon.spy()
        @view.topUp()
        expect( @view.model.next ).to.not.have.been.called

  describe '#updateLoadingState()', ->

    it 'is triggered when model loading state changes', ->
      @view.updateLoadingState = sinon.spy()
      @view.initialize()
      @view.model.trigger 'change:loadingNext'
      expect( @view.updateLoadingState ).to.have.been.calledOnce

    context 'loading next', ->

      beforeEach ->
        @view.model.set 'loadingNext', true, silent: yes

      it 'appends placeholder node', ->
        I18n.t.withArgs( 'widgets.term_list.placeholder' )
          .returns 'loading...'
        @view.updateLoadingState()
        placeholder = @view.$ 'tr.placeholder.next td'
        expect( placeholder ).to.exist
        expect( placeholder ).to.have.text 'loading...'

      it 'appends placeholder only once', ->
        @view.updateLoadingState()
        @view.updateLoadingState()
        placeholder = @view.$ 'tr.placeholder.next'
        expect( placeholder ).to.have.lengthOf 1

    context 'idle', ->

      beforeEach ->
        @view.model.set 'loadingNext', false, silent: yes

      it 'removes placeholder', ->
        @view.$( 'tbody' ).append '''
          <tr class="placeholder next">
            <td>loading ...</td>
          </tr>
        '''
        @view.updateLoadingState()
        placeholder = @view.$ '.placeholder.next'
        expect( placeholder ).to.not.exist

  describe '#toggleScope()', ->

    it 'is triggered by click on toggle', ->
      @view.toggleScope = sinon.spy()
      @view.delegateEvents()
      @view.$( '.toggle-scope' ).click()
      expect(  @view.toggleScope ).to.have.been.calledOnce
      expect(  @view.toggleScope ).to.have.been.calledOn @view

    it 'toggles scope on model', ->
      @view.model.set 'scope', 'all', silent: yes
      @view.toggleScope()
      expect( @view.model.get 'scope' ).to.equal 'hits'
      @view.toggleScope()
      expect( @view.model.get 'scope' ).to.equal 'all'

  describe '#appendItems()', ->

    beforeEach ->
      sinon.stub Coreon.Models.Term::, 'conceptPath', ->
        "/my-repository/concepts/#{@id}"

    afterEach ->
      Coreon.Models.Term::conceptPath.restore()

    it 'is triggered by model', ->
      @view.appendItems = sinon.spy()
      @view.initialize()
      data = []
      @view.model.trigger 'append', data
      expect( @view.appendItems ).to.have.been.calledOnce

    it 'appends items', ->
      @view.$( 'tbody' ).append '''
        <tr class="term">
          <td class="source">
            <a href="#">Ball</a>
          </td>
        </tr>
      '''
      @view.appendItems [
        id: 'concept-123'
        value: 'billiards'
      ]
      expect( @view.$ 'tbody tr.term' ).to.have.property 'length', 2
      added = @view.$('tbody tr.term td.source a').eq(1)
      expect( added ).to.have.text 'billiards'
      expect( added ).to.have.attr 'href', '/my-repository/concepts/concept-123'

    it 'calls top up method', ->
      @view.topUp = sinon.spy()
      @view.appendItems []
      expect( @view.topUp ).to.have.been.calledOnce
