#= require spec_helper
#= require views/panels/concepts_panel

describe 'Coreon.Views.ConceptsPanel', ->

  view = null
  panel = null
  repositoryView = null
  conceptListView = null
  conceptView = null
  newConceptView = null

  beforeEach ->
    repositoryView = new Backbone.View
    @stub Coreon.Views.Panels.Concepts, 'RepositoryView', ->
      repositoryView

    conceptListView = new Backbone.View
    @stub Coreon.Views.Concepts, 'ConceptListView', ->
      conceptListView

    conceptView = new Backbone.View
    @stub Coreon.Views.Concepts, 'ConceptView', ->
      conceptView

    newConceptView = new Backbone.View
    @stub Coreon.Views.Concepts, 'NewConceptView', ->
      newConceptView

    view = new Coreon.Views.Panels.ConceptsPanel
      model: new Backbone.Model
      panel: new Backbone.Model

  it 'is a panel view', ->
    expect(view).to.be.an.instanceOf Coreon.Views.Panels.PanelView

  it 'creates container', ->
    el = view.$el
    expect(el).to.have.attr 'id', 'coreon-concepts'

  describe '#initialize panel: panel', ->

    it 'calls super implementation', ->
      @spy Coreon.Views.Panels.PanelView::, 'initialize'
      panel = new Backbone.Model
      view.initialize panel: panel
      original = Coreon.Views.Panels.PanelView::initialize
      expect(original).to.have.been.calledOnce
      expect(original).to.have.been.calledWith panel: panel

    it 'renders title', ->
      I18n.t.withArgs('panels.concepts.title').returns 'Concepts'
      view.initialize panel: panel
      title = view.$ '.titlebar h3'
      expect(title).to.exist
      expect(title).to.have.text 'Concepts'

    it 'renders container for content', ->
      view.initialize panel: panel
      container = view.$ 'div.content'
      expect(container).to.exist

    it 'switches to appropriate view', ->
      switchView = @spy()
      view.switchView = switchView
      view.initialize panel: panel
      expect(switchView).to.have.been.calledOnce

  describe '#switchView()', ->

    context 'triggers', ->

      spy = null

      beforeEach ->
        spy = @spy()
        view.switchView = spy
        view.initialize panel: panel
        spy.reset()

      it 'is called when selection changes', ->
        view.model.trigger 'change:selection'
        expect(spy).to.have.been.calledOnce
        expect(spy).to.have.been.calledOn view

      it 'is called when scope changes', ->
        view.model.trigger 'change:scope'
        expect(spy).to.have.been.calledOnce
        expect(spy).to.have.been.calledOn view

      it 'is called when repository changes', ->
        view.model.trigger 'change:repository'
        expect(spy).to.have.been.calledOnce
        expect(spy).to.have.been.calledOn view

    context 'cleanup', ->

      it 'removes current view', ->
        remove = @spy()
        currentView = remove: remove
        view.currentView = currentView
        view.switchView()
        expect(remove).to.have.been.calledOnce
        expect(remove).to.have.been.calledOn currentView

      it 'does not fail on pristine instance', ->
        view.currentView = null
        switchView = -> view.switchView
        expect(switchView).to.not.throw Error

    context 'no selection', ->

      beforeEach ->
        view.model.set 'selection', null, silent: yes

      context 'without repository', ->

        beforeEach ->
          view.model.set 'repository', null, silent: yes

        it 'does not create repository view', ->
          constructor = Coreon.Views.Panels.Concepts.RepositoryView
          constructor.reset()
          view.switchView()
          expect(constructor).to.not.have.been.called

      context 'with repository set', ->

        repository = null

        beforeEach ->
          repository = new Backbone.Model
          view.model.set 'repository', repository, silent: yes

        it 'creates repository view', ->
          constructor = Coreon.Views.Panels.Concepts.RepositoryView
          constructor.reset()
          view.switchView()
          expect(constructor).to.have.been.calledOnce
          expect(constructor).to.have.been.calledWithNew
          expect(constructor).to.have.been.calledWith model: repository
          currentView = view.currentView
          expect(currentView).to.equal repositoryView

        it 'appends repository view', ->
          view.switchView()
          content = view.$('.content').get(0)
          el = repositoryView.el
          expect($.contains content, el).to.be.true

        it 'renders repository view', ->
          render = @stub()
          render.returns repositoryView
          repositoryView.render = render
          view.switchView()
          expect(render).to.have.been.calledOnce

    context 'with selection', ->

      selection = null

      beforeEach ->
        selection = new Backbone.Collection
        view.model.set 'selection', selection, silent: yes

      context 'concept listing scope', ->

        beforeEach ->
          view.model.set 'scope', 'index', silent: yes

        it 'creates concept list view', ->
          constructor = Coreon.Views.Concepts.ConceptListView
          constructor.reset()
          view.switchView()
          expect(constructor).to.have.been.calledOnce
          expect(constructor).to.have.been.calledWithNew
          expect(constructor).to.have.been.calledWith model: selection
          currentView = view.currentView
          expect(currentView).to.equal conceptListView

        it 'appends concept list view', ->
          view.switchView()
          content = view.$('.content').get(0)
          el = conceptListView.el
          expect($.contains content, el).to.be.true

        it 'renders concept list view', ->
          render = @stub()
          render.returns conceptListView
          conceptListView.render = render
          view.switchView()
          expect(render).to.have.been.calledOnce

      context 'pager scope', ->

        concept = null

        beforeEach ->
          view.model.set 'scope', 'pager', silent: yes
          concept = new Backbone.Model
          selection.add concept

        context 'persisted concept', ->

          beforeEach ->
            concept.isNew = -> no

          it 'creates concept view', ->
            constructor = Coreon.Views.Concepts.ConceptView
            constructor.reset()
            view.switchView()
            expect(constructor).to.have.been.calledOnce
            expect(constructor).to.have.been.calledWithNew
            expect(constructor).to.have.been.calledWith model: concept
            currentView = view.currentView
            expect(currentView).to.equal conceptView

          it 'appends concept view', ->
            view.switchView()
            content = view.$('.content').get(0)
            el = conceptView.el
            expect($.contains content, el).to.be.true

          it 'renders concept view', ->
            render = @stub()
            render.returns conceptView
            conceptView.render = render
            view.switchView()
            expect(render).to.have.been.calledOnce

        context 'new concept', ->

          beforeEach ->
            concept.isNew = -> yes

          it 'creates new concept view', ->
            constructor = Coreon.Views.Concepts.NewConceptView
            constructor.reset()
            view.switchView()
            expect(constructor).to.have.been.calledOnce
            expect(constructor).to.have.been.calledWithNew
            expect(constructor).to.have.been.calledWith model: concept
            currentView = view.currentView
            expect(currentView).to.equal newConceptView

          it 'appends new concept view', ->
            view.switchView()
            content = view.$('.content').get(0)
            el = newConceptView.el
            expect($.contains content, el).to.be.true

          it 'renders new concept view', ->
            render = @stub()
            render.returns newConceptView
            newConceptView.render = render
            view.switchView()
            expect(render).to.have.been.calledOnce

  describe '#render()', ->

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    it 'delegates to current view', ->
      render = @spy()
      view.currentView = render: render
      view.render()
      expect(render).to.have.been.calledOnce
