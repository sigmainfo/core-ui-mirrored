#= require spec_helper
#= require views/panels/concepts_panel

describe 'Coreon.Views.Panels.ConceptsPanel', ->

  view = null
  repositoryView = null
  conceptListView = null
  conceptView = null

  beforeEach ->
    sinon.stub I18n, 't'

    repositoryView = new Backbone.View
    sinon.stub Coreon.Views.Panels.Concepts, 'RepositoryView', ->
      repositoryView

    conceptListView = new Backbone.View
    sinon.stub Coreon.Views.Panels.Concepts, 'ConceptListView', ->
      conceptListView

    conceptView = new Backbone.View
    sinon.stub Coreon.Views.Panels.Concepts, 'ConceptView', ->
      conceptView

    view = new Coreon.Views.Panels.ConceptsPanel
      model: new Backbone.Model

  afterEach ->
    Coreon.Views.Panels.Concepts.RepositoryView.restore()
    Coreon.Views.Panels.Concepts.ConceptListView.restore()
    Coreon.Views.Panels.Concepts.ConceptView.restore()
    I18n.t.restore()

  it 'is a panel view', ->
    expect(view).to.be.an.instanceOf Coreon.Views.Panels.PanelView

  describe '#initialize()', ->

    it 'renders title', ->
      I18n.t.withArgs('panels.concepts.title').returns 'Concepts'
      view.initialize()
      title = view.$ '.titlebar h3'
      expect(title).to.exist
      expect(title).to.have.text 'Concepts'

    it 'renders container for content', ->
      view.initialize()
      container = view.$ 'div.content'
      expect(container).to.exist

    it 'switches to appropriate view', ->
      switchView = sinon.spy()
      view.switchView = switchView
      view.initialize()
      expect(switchView).to.have.been.calledOnce

  describe '#switchView()', ->

    context 'triggers', ->

      spy = null

      beforeEach ->
        spy = sinon.spy()
        view.switchView = spy
        view.initialize()
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
        remove = sinon.spy()
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

      it 'creates repository view', ->
        constructor = Coreon.Views.Panels.Concepts.RepositoryView
        constructor.reset()
        repository = new Backbone.Model
        view.model.set 'repository', repository, silent: yes
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
        render = sinon.stub()
        render.returns repositoryView
        repositoryView.render = render
        view.switchView()
        expect(render).to.have.been.calledOnce

    context 'with selection', ->

      selection = new Backbone.Collection

      beforeEach ->
        view.model.set 'selection', selection, silent: yes

      context 'concept listing scope', ->

        beforeEach ->
          view.model.set 'scope', 'all', silent: yes

        it 'creates concept list view', ->
          constructor = Coreon.Views.Panels.Concepts.ConceptListView
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
          render = sinon.stub()
          render.returns conceptListView
          conceptListView.render = render
          view.switchView()
          expect(render).to.have.been.calledOnce

      context 'single concept scope', ->

        beforeEach ->
          view.model.set 'scope', 'single', silent: yes

        it 'creates concept view', ->
          constructor = Coreon.Views.Panels.Concepts.ConceptView
          constructor.reset()
          concept = new Backbone.Model
          selection.add concept
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
          render = sinon.stub()
          render.returns conceptView
          conceptView.render = render
          view.switchView()
          expect(render).to.have.been.calledOnce

  describe '#render()', ->

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    it 'delegates to current view', ->
      render = sinon.spy()
      view.currentView = render: render
      view.render()
      expect(render).to.have.been.calledOnce
