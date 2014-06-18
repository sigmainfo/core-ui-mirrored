#= require spec_helper
#= require views/panels/term_list_panel

describe 'Coreon.Views.Panels.TermListPanel', ->

  view = null
  panel = null

  beforeEach ->
    sinon.stub I18n, "t"
    sinon.stub Coreon.Models.Concept, 'find'
    concept = new Backbone.Model
    Coreon.Models.Concept.find.returns concept
    repository = new Backbone.Model
    settings = new Backbone.Model
    Coreon.application =
      repositorySettings: sinon.stub().returns settings
      repository: -> repository
    model = new Backbone.Model
    model.hits = new Backbone.Collection
    model.terms = new Backbone.Collection
    model.hasNext = -> no
    model.hasPrev = -> no
    panel = new Backbone.Model widget: on
    view = new Coreon.Views.Panels.TermListPanel
      model: model
      panel: panel
    view.widgetize()

  afterEach ->
    I18n.t.restore()
    Coreon.Models.Concept.find.restore()

  it 'is a panel view', ->
    expect(view).to.be.an.instanceOf Coreon.Views.Panels.PanelView

  it 'creates container', ->
    expect( view.$el ).to.have.id 'coreon-term-list'

  describe '#initialize()', ->

    it 'calls super implementation', ->
      sinon.spy Coreon.Views.Panels.PanelView::, 'initialize'
      try
        panel = new Backbone.Model
        view.initialize panel: panel
        original = Coreon.Views.Panels.PanelView::initialize
        expect(original).to.have.been.calledOnce
        expect(original).to.have.been.calledWith panel: panel
      finally
        Coreon.Views.Panels.PanelView::initialize.restore()

    it 'renders title', ->
      I18n.t.withArgs('panels.term_list.title').returns 'Term List'
      view.initialize panel: panel
      title = view.$( '.titlebar h3' )
      expect( title ).to.exist
      expect( title ).to.contain 'Term List'
      expect( title.find '.langs' ).to.not.exist

    it 'renders source in title', ->
      view.model.set 'source', 'en', silent: yes
      view.initialize panel: panel
      expect( view.$ '.titlebar h3 .langs' ).to.have.text '(EN)'

    it 'renders target in title', ->
      view.model.set 'source', 'en', silent: yes
      view.model.set 'target', 'hu', silent: yes
      view.initialize panel: panel
      expect( view.$ '.titlebar h3 span.langs' ).to.have.text '(EN, HU)'

    it 'renders toggle button', ->
      I18n.t.withArgs('panels.term_list.toggle_scope.label').returns 'Toggle scope'
      view.initialize panel: panel
      toggle = view.$('.toggle-scope')
      expect( toggle ).to.exist
      expect( toggle ).to.have.attr 'href', 'javascript:void(0)'
      expect( toggle ).to.have.text 'Toggle scope'

  describe '#render()', ->

    it 'can be chained', ->
      expect( view.render() ).to.equal view

    it 'is triggered on model updates', ->
      view.render = sinon.spy()
      view.initialize panel: panel
      view.model.trigger 'reset'
      expect( view.render ).to.have.been.calledOnce
      expect( view.render ).to.have.been.calledOn view

    it 'resets scroll position', ->
      $( '#konacha' ).append view.$el
      inner = view.$ 'tbody'
      inner.height 200
      outer = view.$ 'table'
      outer.height 100
      outer.scrollTop 25
      view.render()
      expect( outer.scrollTop() ).to.equal 0

    context 'no source language', ->

      beforeEach ->
        view.model.set 'source', null, silent: yes

      it 'renders info', ->
        I18n.t.withArgs('panels.term_list.empty').returns 'No language selected'
        view.render()
        expect( view.$el ).to.have 'tbody tr.empty'
        expect( view.$('tr.empty td') ).to.have.text 'No language selected'

    context 'with selected source language', ->

      beforeEach ->
        view.model.set 'source', 'en', silent: yes

      it 'does not render info', ->
        I18n.t.withArgs('panels.term_list.empty').returns 'No language selected'
        view.$('ul').append '<li class="empty">No language selected</li>'
        view.render()
        expect( view.$el ).to.not.have '.empty'
        expect( view.$el ).to.not.have.text 'No language selected'

      it 'renders terms', ->
        view.model.terms.reset ['billiards', 'cue', 'pocket billiards'].map ( value ) ->
          term = new Backbone.Model value: value
          term.conceptPath = -> ''
          term
        , silent: yes
        view.render()
        expect( view.$ 'tbody' ).to.have 'tr.term td.source'
        expect( view.$ 'tbody tr.term td.source' ).to.have.property 'length'
                                                                   , 3
        expect( view.$('tbody tr.term:nth-child(1) td.source').text() )
          .to.contain 'billiards'
        expect( view.$('tbody tr.term:nth-child(2) td.source').text() )
          .to.contain 'cue'
        expect( view.$('tbody tr.term:nth-child(3) td.source').text() )
          .to.contain 'pocket billiards'

      it 'renders link to concept', ->
        term = new Backbone.Model value: 'billiards'
        term.conceptPath = -> '/my-repository/concepts/concept-123'
        view.model.terms.reset [ term ], silent: yes
        view.render()
        link = view.$ 'tbody td.source a'
        expect( link ).to.exist
        expect( link ).to.have.attr 'href', '/my-repository/concepts/concept-123'
        expect( link ).to.have.text 'billiards'

      it 'clasifies hits', ->
        view.model.terms.reset ['billiards', 'cue', 'pocket billiards'].map ( value, index ) =>
          term = new Backbone.Model value: value
          term.conceptPath = -> ''
          term
        , silent: yes
        view.model.hits.reset [ view.model.terms.at(1) ], silent: yes
        view.render()
        expect( view.$ 'tbody' ).to.have 'tr.term.hit'
        expect( view.$ 'tbody tr.term.hit' ).to.have.property 'length', 1
        expect( view.$('tbody tr.term:nth-child(1)') ).to.not.have.class 'hit'
        expect( view.$('tbody tr.term:nth-child(2)') ).to.have.class 'hit'
        expect( view.$('tbody tr.term:nth-child(3)') ).to.not.have.class 'hit'

      it 'identifies term list items', ->
        term = new Backbone.Model id: '52fe4156ec4d'
        term.conceptPath = -> ''
        view.model.terms.reset [ term ], silent: yes
        view.render()
        expect( view.$ 'tbody tr.term' ).to.have.attr 'data-id'
                                                     , '52fe4156ec4d'

      it 'renders translations', ->
        term = new Backbone.Model concept_id: '52fe4156ec4d'
        term.conceptPath = -> ''
        terms = lang: sinon.stub()
        terms.lang.withArgs( 'de' ).returns [
          new Backbone.Model( value: 'Ball' )
          new Backbone.Model( value: 'Kugel' )
        ]
        concept = terms: -> terms
        Coreon.Models.Concept.find.withArgs( '52fe4156ec4d' ).returns concept
        view.model.terms.reset [ term ], silent: yes
        view.model.set 'target', 'de', silent: yes
        view.render()
        translation = view.$( 'tbody tr.term td.target ul' )
        expect( translation ).to.exist
        terms = translation.find 'li'
        expect( terms ).to.have.lengthOf 2
        expect( terms.eq 0 ).to.have.text 'Ball'
        expect( terms.eq 1 ).to.have.text 'Kugel'

      it 'renders empty target column when translations are empty', ->
        term = new Backbone.Model concept_id: '52fe4156ec4d'
        term.conceptPath = -> ''
        terms = lang: sinon.stub()
        terms.lang.withArgs( 'de' ).returns []
        concept = terms: -> terms
        Coreon.Models.Concept.find.withArgs( '52fe4156ec4d' ).returns concept
        view.model.terms.reset [ term ], silent: yes
        view.model.set 'target', 'de', silent: yes
        view.render()
        translation = view.$( 'tbody tr.term td.target ul' )
        expect( translation ).to.exist
        expect( translation.find 'li' ).to.have.lengthOf 0

      it 'does not render target column when no target lang is set', ->
        term = new Backbone.Model concept_id: '52fe4156ec4d'
        term.conceptPath = -> ''
        terms = lang: sinon.stub()
        terms.lang.withArgs( 'de' ).returns []
        concept = terms: -> terms
        Coreon.Models.Concept.find.withArgs( '52fe4156ec4d' ).returns concept
        view.model.terms.reset [ term ], silent: yes
        view.model.set 'target', null, silent: yes
        view.render()
        translation = view.$( 'tbody tr.term td.target' )
        expect( translation ).to.not.exist

  describe '#topUp()', ->

    beforeEach ->
      $('#konacha').append view.$el

    it 'is triggered on scroll', ->
      view.topUp = sinon.spy()
      view.delegateEvents()
      view.$( 'tbody' ).scroll()
      expect( view.topUp ).to.have.been.calledOnce
      expect( view.topUp ).to.have.been.calledOn view

    context 'tail', ->

      beforeEach ->
        view.$('table').height 100
        view.$('tbody').height 120
        view.model.next = sinon.spy =>
          @deferred = $.Deferred()
          @deferred.promise()

      context 'not yet completely loaded', ->

        beforeEach ->
          view.model.hasNext = -> yes

        it 'calls next on model', ->
          view.topUp()
          expect( view.model.next ).to.have.been.calledOnce

        context 'loading', ->

          beforeEach ->
            view.model.set 'loadingNext', on, silent: yes

          it 'does not call next on model', ->
            view.topUp()
            expect( view.model.next ).to.not.have.been.called

        context 'far away from tail', ->

          beforeEach ->
            view.$('table').height 100
            view.$('tbody').height 300

          it 'does not call next on model', ->
            view.model.next = sinon.spy()
            view.topUp()
            expect( view.model.next ).to.not.have.been.called

      context 'completely loaded', ->

        beforeEach ->
          view.model.hasNext = -> no

        it 'does not call next on model', ->
          view.topUp()
          expect( view.model.next ).to.not.have.been.called


    context 'head', ->

      beforeEach ->
        view.$('table')
          .height( 100 )
          .scrollTop 10
        view.$('tbody').height 120
        view.model.prev = sinon.spy =>
          @deferred = $.Deferred()
          @deferred.promise()

      context 'not yet completely loaded', ->

        beforeEach ->
          view.model.hasPrev = -> yes

        it 'calls prev on model', ->
          view.model.terms.length = 4
          view.topUp()
          expect( view.model.prev ).to.have.been.calledOnce

        it 'does not call prev on model when empty', ->
          view.model.terms.length = 0
          view.topUp()
          expect( view.model.prev ).to.not.have.been.called

        context 'loading', ->

          beforeEach ->
            view.model.set 'loadingPrev', on, silent: yes

          it 'does not call prev on model', ->
            view.topUp()
            expect( view.model.prev ).to.not.have.been.called

        context 'far away from head', ->

          beforeEach ->
            view.$('tbody')
              .height 300
            view.$('table')
              .height( 100 )
              .scrollTop 200

          it 'does not call prev on model', ->
            view.model.prev = sinon.spy()
            view.topUp()
            expect( view.model.prev ).to.not.have.been.called

      context 'completely loaded', ->

        beforeEach ->
          view.model.hasPrev = -> no

        it 'does not call prev on model', ->
          view.topUp()
          expect( view.model.prev ).to.not.have.been.called

  describe '#updateLoadingState()', ->

    it 'is triggered when model loads next', ->
      view.updateLoadingState = sinon.spy()
      view.initialize panel: panel
      view.model.trigger 'change:loadingNext'
      expect( view.updateLoadingState ).to.have.been.calledOnce

    it 'is triggered when model loads prev', ->
      view.updateLoadingState = sinon.spy()
      view.initialize panel: panel
      view.model.trigger 'change:loadingPrev'
      expect( view.updateLoadingState ).to.have.been.calledOnce

    context 'loading next', ->

      beforeEach ->
        view.model.set 'loadingNext', true, silent: yes

      it 'appends placeholder node', ->
        I18n.t.withArgs( 'panels.term_list.placeholder' )
          .returns 'loading...'
        view.updateLoadingState()
        placeholder = view.$ 'tr.placeholder.next td'
        expect( placeholder ).to.exist
        expect( placeholder ).to.have.text 'loading...'

      it 'appends placeholder only once', ->
        view.updateLoadingState()
        view.updateLoadingState()
        placeholder = view.$ 'tr.placeholder.next'
        expect( placeholder ).to.have.lengthOf 1

    context 'loading prev', ->

      beforeEach ->
        view.model.set 'loadingPrev', true, silent: yes

      it 'appends placeholder node', ->
        I18n.t.withArgs( 'panels.term_list.placeholder' )
          .returns 'loading...'
        view.updateLoadingState()
        placeholder = view.$ 'tr.placeholder.prev td'
        expect( placeholder ).to.exist
        expect( placeholder ).to.have.text 'loading...'

      it 'appends placeholder only once', ->
        view.updateLoadingState()
        view.updateLoadingState()
        placeholder = view.$ 'tr.placeholder.prev'
        expect( placeholder ).to.have.lengthOf 1

    context 'idle', ->

      it 'removes next placeholder', ->
        view.model.set 'loadingNext', false, silent: yes
        view.$( 'tbody' ).append '''
          <tr class="placeholder next">
            <td>loading ...</td>
          </tr>
        '''
        view.updateLoadingState()
        placeholder = view.$ '.placeholder.next'
        expect( placeholder ).to.not.exist

      it 'removes prev placeholder', ->
        view.model.set 'loadingPrev', false, silent: yes
        view.$( 'tbody' ).append '''
          <tr class="placeholder prev">
            <td>loading ...</td>
          </tr>
        '''
        view.updateLoadingState()
        placeholder = view.$ '.placeholder.prev'
        expect( placeholder ).to.not.exist

  describe '#toggleScope()', ->

    it 'is triggered by click on toggle', ->
      view.toggleScope = sinon.spy()
      view.delegateEvents()
      view.$( '.toggle-scope' ).click()
      expect(  view.toggleScope ).to.have.been.calledOnce
      expect(  view.toggleScope ).to.have.been.calledOn view

    it 'limits scope when expanded', ->
      view.model.set 'scope', 'all', silent: yes
      view.limitScope = sinon.spy()
      view.toggleScope()
      expect( view.limitScope ).to.have.been.calledOnce
      expect( view.limitScope ).to.have.been.calledOn view

    it 'expands scope when limited', ->
      view.model.set 'scope', 'hits', silent: yes
      view.expandScope = sinon.spy()
      view.toggleScope()
      expect( view.expandScope ).to.have.been.calledOnce
      expect( view.expandScope ).to.have.been.calledOn view

  describe '#limitScope()', ->

    beforeEach ->
      view.model.set 'scope', 'all', silent: yes
      anchorHit = new Backbone.Model id: 'anchor-123'
      view.anchorHit = -> anchorHit
      $( '#konacha' ).append view.$el
      @anchor = $ '<tr class="term hit" data-id="anchor-123">'
      view.$( 'tbody' ).append @anchor

    it 'changes scope on model', ->
      view.limitScope()
      expect( view.model.get 'scope' ).to.equal 'hits'

    it 'triggers change event', ->
      spy = sinon.spy()
      view.model.on 'change:scope', spy
      view.limitScope()
      expect( spy ).to.have.been.calledOnce

    it 'pins anchor hit on top', ->
      $( '#konacha' ).append view.el
      inner = view.$( 'tbody' ).height( 200 )
      outer = view.$( 'table' ).height( 100 )
      view.limitScope()
      offset = @anchor.position().top - 6
      expect( outer.scrollTop() ).to.equal offset

  describe '#expandScope()', ->

    beforeEach ->
      view.anchor = -> $( '<tr class="term hit" data-id="543ffaa23">' )
      view.model.set 'scope', 'hits', silent: yes
      view.model.clearTerms = sinon.spy()
      view.model.next = sinon.spy()

    it 'changes scope on model', ->
      view.expandScope()
      expect( view.model.get 'scope' ).to.equal 'all'

    it 'does not trigger change event', ->
      spy = sinon.spy()
      view.model.on 'change:scope', spy
      view.expandScope()
      expect( spy ).to.not.have.been.called

    it 'clears model', ->
      view.expandScope()
      expect( view.model.clearTerms ).to.have.been.calledOnce

    it 'fetches next terms', ->
      view.anchor = -> $( '<tr class="term hit" data-id="543ffaa23">' )
      view.expandScope()
      expect( view.model.next ).to.have.been.calledOnce
      expect( view.model.next ).to.have.been.calledWith '543ffaa23'

  describe '#anchor()', ->

    beforeEach ->
      $('#konacha').append view.$el
      @outer = view.$ 'table'
      @outer.height 100
      @inner = view.$ 'tbody'

    it 'returns null for empty list', ->
      @inner.html ''
      anchor = view.anchor()
      expect( anchor ).to.be.null

    it 'selects first visible item', ->
      @inner.html '''
        <tr class="term"><td>term 1</td></tr>
        <tr class="term"><td>term 2</td></tr>
        <tr class="term"><td>term 3</td></tr>
      '''
      @inner.find( 'tr' ).height 50
      @outer.scrollTop 30
      anchor = view.anchor()
      expect( anchor ).to.match 'tr.term:nth-child(2)'

  describe '#appendItems()', ->

    it 'is triggered by model', ->
      view.appendItems = sinon.spy()
      view.initialize panel: panel
      data = []
      view.model.trigger 'append', data
      expect( view.appendItems ).to.have.been.calledOnce

    it 'appends items', ->
      view.$( 'tbody' ).append '''
        <tr class="term">
          <td class="source">
            <a href="#">Ball</a>
          </td>
        </tr>
      '''
      view.appendItems [
        id: 'concept-123'
        get: (attr) -> 'billiards' if attr is 'value'
        conceptPath: -> '/my-repository/concepts/concept-123'
      ]
      expect( view.$ 'tbody tr.term' ).to.have.property 'length', 2
      added = view.$( 'tbody tr.term td.source a' ).eq( 1 )
      expect( added ).to.have.text 'billiards'
      expect( added ).to.have.attr 'href', '/my-repository/concepts/concept-123'

    it 'calls top up method', ->
      view.topUp = sinon.spy()
      view.appendItems []
      expect( view.topUp ).to.have.been.calledOnce

  describe '#prependItems()', ->

    it 'is triggered by model', ->
      view.prependItems = sinon.spy()
      view.initialize panel: panel
      data = []
      view.model.trigger 'prepend', data
      expect( view.prependItems ).to.have.been.calledOnce

    it 'prepends items', ->
      view.$( 'tbody' ).append '''
        <tr class="term">
          <td class="source">
            <a href="#">Ball</a>
          </td>
        </tr>
      '''
      view.prependItems [
        id: 'concept-123'
        get: (attr) -> 'billiards' if attr is 'value'
        conceptPath: -> '/my-repository/concepts/concept-123'
      ]
      expect( view.$ 'tbody tr.term' ).to.have.property 'length', 2
      added = view.$( 'tbody tr.term td.source a' ).eq( 0 )
      expect( added ).to.have.text 'billiards'
      expect( added ).to.have.attr 'href', '/my-repository/concepts/concept-123'

    it 'calls top up method', ->
      view.topUp = sinon.spy()
      view.prependItems []
      expect( view.topUp ).to.have.been.calledOnce

    it 'pins scroll position', ->
      $( '#konacha' ).append view.$el
      inner = view.$ 'tbody'
      inner
        .height( 200 )
        .append( '<tr class="term">' )
      outer = view.$ 'table'
      outer
        .height( 100 )
        .scrollTop( 5 )
      before = view.$( '.term:last' ).position().top
      view.prependItems [
        id: 'concept-123'
        get: (attr) -> 'billiards' if attr is 'value'
        conceptPath: -> '/my-repository/concepts/concept-123'
      ]
      after = view.$( '.term:last' ).position().top
      expect( outer.scrollTop() ).to.equal 5 + after - before

  describe '#anchorHit()', ->

    beforeEach ->
      view.anchor = sinon.stub()
      view.model.hits = new Backbone.Collection
      view.model.hits.lang = sinon.stub()
      view.model.hits.lang.returns []
      view.model.set 'source', 'hu', silent: yes

    it 'returns null when no anchor exists', ->
      view.anchor.returns null
      anchorHit = view.anchorHit()
      expect( anchorHit ).to.be.null

    it 'returns term of anchor when it is a hit', ->
      anchor = $ '<tr class="term hit" data-id="543eff34">'
      view.anchor.returns anchor
      hit = new Backbone.Model id: '543eff34'
      view.model.hits.reset [ hit ], silent: true
      view.model.terms.reset [
        new Backbone.Model( id: '4567ff' )
        hit
        new Backbone.Model( id: '1567f3' )
      ], silent: true
      anchorHit = view.anchorHit()
      expect( anchorHit ).to.equal hit

    it 'returns first term hit following anchor', ->
      anchor = $ '<tr class="term" data-id="543eff34">'
      view.anchor.returns anchor
      term = new Backbone.Model id: '543eff34', sort_key: '183ffe52'
      view.model.terms.reset [ term ], silent: yes
      view.model.hits.lang.withArgs( 'hu' ).returns [
        new Backbone.Model( id: '543eff31', 'sort_key': '1115f' )
        new Backbone.Model( id: '543eff32', 'sort_key': '183ffe589' )
        new Backbone.Model( id: '543eff33', 'sort_key': '183ffe589345' )
      ]
      anchorHit = view.anchorHit()
      expect( anchorHit.id ).to.equal '543eff32'

    it 'returns last hit if it is before anchor', ->
      anchor = $ '<tr class="term" data-id="543eff34">'
      view.anchor.returns anchor
      term = new Backbone.Model id: '543eff34', sort_key: 'f976fe525'
      view.model.terms.reset [ term ], silent: yes
      view.model.hits.lang.withArgs( 'hu' ).returns [
        new Backbone.Model( id: '543eff31', 'sort_key': '1115f' )
        new Backbone.Model( id: '543eff32', 'sort_key': '183ffe589' )
        new Backbone.Model( id: '543eff33', 'sort_key': '183ffe589345' )
      ]
      anchorHit = view.anchorHit()
      expect( anchorHit.id ).to.equal '543eff33'

  describe '#updateTargetLang()', ->

    it 'is triggered by change on model', ->
      view.updateTargetLang = sinon.spy()
      view.initialize panel: panel
      view.model.trigger 'change:target'
      expect( view.updateTargetLang ).to.have.been.calledOnce

    it 'removes target column when empty', ->
      list = view.$( 'table tbody' )
      list.append '''
        <tr class="term">
          <td class="source">ball</td>
          <td class="target">Ball, Kugel</td>
        </tr>
        <tr class="term">
          <td class="source">billiards</td>
          <td class="target"></td>
        </tr>
      '''
      view.model.set 'target', null, silent: yes
      view.updateTargetLang()
      targets = view.$( 'td.target' )
      expect( targets ).to.have.lengthOf 0

    it 'creates target column when lang was set', ->
      list = view.$( 'table tbody' )
      list.append '''
        <tr class="term">
          <td class="source">ball</td>
        </tr>
        <tr class="term">
          <td class="source">billiards</td>
        </tr>
        <tr class="term">
          <td class="source">cue</td>
        </tr>
      '''
      view.model.set 'target', 'de', silent: yes
      view.translations = -> ''
      view.updateTargetLang()
      targets = view.$( 'td.target' )
      expect( targets ).to.have.lengthOf 3

    it 'creates target column only once', ->
      list = view.$( 'table tbody' )
      list.append '''
        <tr class="term">
          <td class="source">ball</td>
        </tr>
        <tr class="term">
          <td class="source">billiards</td>
        </tr>
        <tr class="term">
          <td class="source">cue</td>
        </tr>
      '''
      view.model.set 'target', 'de', silent: yes
      view.translations = -> ''
      view.updateTargetLang()
      view.model.set 'target', 'hu', silent: yes
      view.updateTargetLang()
      targets = view.$( 'td.target' )
      expect( targets ).to.have.lengthOf 3

    it 'updates translations', ->
      list = view.$( 'table tbody' )
      list.append '''
        <tr class="term" data-id="54ff4320001">
          <td class="source">ball</td>
          <td class="target">labda</td>
        </tr>
      '''
      view.model.set 'target', 'de', silent: yes
      term = new Backbone.Model
        id: '54ff4320001'
        concept_id: '52fe4156ec4d'
      terms = lang: sinon.stub()
      terms.lang.withArgs( 'de' ).returns [
        new Backbone.Model( value: 'Ball' )
        new Backbone.Model( value: 'Kugel' )
      ]
      concept = terms: -> terms
      Coreon.Models.Concept.find.withArgs( '52fe4156ec4d' ).returns concept
      view.model.terms.reset [ term ], silent: yes
      view.updateTargetLang()
      target = view.$( 'td.target li' )
      expect( target ).to.have.lengthOf 2
      expect( target.eq 0 ).to.have.text 'Ball'
      expect( target.eq 1 ).to.have.text 'Kugel'

  describe '#updateTranslations()', ->

    it 'is triggered by model event', ->
      view.updateTranslations = sinon.spy()
      view.initialize panel: panel
      view.model.trigger 'updateTargetTerms', [ new Backbone.Model ]
      expect( view.updateTranslations ).to.have.been.calledOnce

    it 'renders translations for updated term', ->
      list = view.$( 'table tbody' )
      list.append '''
        <tr class="term" data-id="54ff4320001">
          <td class="source">ball</td>
          <td class="target">labda</td>
        </tr>
      '''
      terms = [
        new Backbone.Model( concept_id: '52fe4156ec4d', value: 'Ball' )
        new Backbone.Model( concept_id: '52fe4156ec4d', value: 'Kugel' )
      ]
      lang = sinon.stub()
      lang.withArgs( 'en' ).returns [
        new Backbone.Model concept_id: '52fe4156ec4d', id: '54ff4320001'
      ]
      lang.withArgs( 'de' ).returns terms
      concept = terms: -> lang: lang
      Coreon.Models.Concept.find.withArgs( '52fe4156ec4d' ).returns concept
      view.model.set 'source', 'en', silent: yes
      view.model.set 'target', 'de', silent: yes
      view.updateTranslations terms
      target = view.$( 'td.target li' )
      expect( target ).to.have.lengthOf 2
      expect( target.eq 0 ).to.have.text 'Ball'
      expect( target.eq 1 ).to.have.text 'Kugel'

  describe '#updateLangs()', ->

    it 'is triggered by change of source lang', ->
      view.updateLangs = sinon.spy()
      view.initialize panel: panel
      view.model.trigger 'change:source'
      expect( view.updateLangs ).to.have.been.calledOnce

    it 'is triggered by change of target lang', ->
      view.updateLangs = sinon.spy()
      view.initialize panel: panel
      view.model.trigger 'change:target'
      expect( view.updateLangs ).to.have.been.calledOnce

    it 'renders source in title', ->
      view.model.set 'source', 'en', silent: yes
      view.model.set 'target', null, silent: yes
      view.updateLangs()
      expect( view.$ '.titlebar h3 span.langs' ).to.have.text '(EN)'

    it 'renders target in title', ->
      view.model.set 'source', 'en', silent: yes
      view.model.set 'target', 'hu', silent: yes
      view.updateLangs()
      expect( view.$ '.titlebar h3 span.langs' ).to.have.text '(EN, HU)'

    it 'removes langs from title', ->
      view.model.set 'source', null, silent: yes
      view.model.set 'target', null, silent: yes
      view.$( '.titlebar h4 .langs' ).html '(DE, EN)'
      view.updateLangs()
      expect( view.$ '.titlebar h3 span.langs' ).to.not.exist

  describe '#openConcept()', ->

    beforeEach ->
      sinon.stub Backbone.history, 'navigate'
      view.$el.html '''
        <table>
          <tr class="term">
            <td class="source"><a href="/concepts/52334519fe">ball</a></td>
          </tr>
          <tr class="term">
            <td class="source"><a href="/concepts/12334519a0">cue</a></td>
          </tr>
        </table>
      '''
      @td = view.$( 'tr.term td' ).last()
      @event = $.Event 'click'
      @event.target = @td.get( 0 )

    afterEach ->
      Backbone.history.navigate.restore()

    it 'is triggered by click on term row', ->
      view.openConcept = sinon.spy()
      view.delegateEvents()
      @td.trigger @event
      expect( view.openConcept ).to.have.been.calledOnce
      expect( view.openConcept ).to.have.been.calledOn view
      expect( view.openConcept ).to.have.been.calledWith @event

    it 'eats event', ->
      @event.stopPropagation = sinon.spy()
      @event.preventDefault = sinon.spy()
      view.openConcept @event
      expect( @event.stopPropagation ).to.have.been.calledOnce
      expect( @event.preventDefault ).to.have.been.calledOnce

    it 'navigates to related concept', ->
      @td.find( 'a' ).attr 'href', '/concepts/52fe4156ec4d'
      view.openConcept @event
      navigate = Backbone.history.navigate
      expect( navigate ).to.have.been.calledOnce
      expect( navigate ).to.have.been.calledWith 'concepts/52fe4156ec4d'
                                               , trigger: yes
