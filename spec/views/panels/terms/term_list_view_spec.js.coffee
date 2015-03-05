#= require spec_helper
#= require views/panels/terms/term_list_view
#= require helpers/can

describe 'Coreon.Views.Panels.Terms.TermListView', ->

  view = null
  model = null
  terms = null

  createTerm = (attrs) ->
    term = new Backbone.Model(attrs)
    term.properties = -> attrs.properties || []
    term

  beforeEach ->
    Coreon.application = new Backbone.Model
    Coreon.application.repositorySettings = ->
    Coreon.application.langs = -> []
    Coreon.application.sourceLang = -> 'none'
    Coreon.application.targetLang = -> 'none'
    sinon.stub Coreon.Helpers, 'can', -> true
    model =
      terms: -> terms
    view = new Coreon.Views.Panels.Terms.TermListView model: model

  afterEach ->
    Coreon.Helpers.can.restore()

  it 'is a backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'has a container', ->
    el = view.$el
    expect(el).to.have.class 'terms'

  describe '#render()', ->

    markup = null

    beforeEach ->
      termViewStub = sinon.stub Coreon.Views.Panels.Terms, 'TermView', ->
        render: ->
          $el: $ markup
      editTermViewStub = sinon.stub Coreon.Views.Panels.Terms, 'EditTermView', ->
        render: ->
          $el: $ markup

    afterEach ->
      Coreon.Views.Panels.Terms.TermView.restore()
      Coreon.Views.Panels.Terms.EditTermView.restore()

    it 'renders a "toggle all properties link" even if one term has properties', ->
      terms = [createTerm({lang: 'en', value: 'test', properties: [{}]})]
      el = view.render().$el
      expect(el).to.have 'h4.properties-toggle'

    it 'renders and add term link', ->
      el = view.render().$el
      expect(el).to.have 'a.add-term'

    it 'renders sections of grouped terms', ->
      terms = [
        createTerm({lang: 'en', value: 'car'}),
        createTerm({lang: 'de', value: 'auto'})
      ]
      el = view.render().$el
      sections = view.$('section.language')
      expect(sections).to.have.lengthOf 2
      expect(sections.first()).to.contain 'en'
      expect(sections.last()).to.contain 'de'

    # it 'renders "terms empty" message for group with no terms', ->
    #   sinon.stub(I18n, 't').withArgs('terms.empty').returns 'empty'
    #   terms = [
    #     createTerm({lang: 'de'})
    #   ]
    #   el = view.render().$el
    #   section = view.$('section.language').first()
    #   expect(section).to.contain 'empty'

    it 'renders terms for each language group', ->
      terms = [
        createTerm({lang: 'en', value: 'car'}),
        createTerm({lang: 'de', value: 'auto'})
      ]
      el = view.render().$el
      expect(Coreon.Views.Panels.Terms.TermView).to.have.been.calledTwice

    it 'renders an add term link for each language group', ->
      terms = [
        createTerm({lang: 'en', value: 'car'}),
        createTerm({lang: 'de', value: 'auto'})
      ]
      el = view.render().$el
      addTtermLinks = el.find('a.add-term')
      expect(addTtermLinks).to.have.lengthOf 3

    it 'renders terms in edit mode if term is being edited', ->
      terms = [
        createTerm({lang: 'en', id: 1, value: 'car'}),
        createTerm({lang: 'de', id: 2, value: 'auto'})
      ]
      view.setEditMode true
      view.setEditTerm 2
      el = view.render().$el
      expect(Coreon.Views.Panels.Terms.TermView).to.have.been.calledOnce
      expect(Coreon.Views.Panels.Terms.EditTermView).to.have.been.calledOnce

  describe '#hasTermProperties()', ->

    it 'returns false if no term has even one property', ->
      terms.en = [createTerm(value: 'car')]
      result = view.hasTermProperties()
      expect(result).to.be.false

    it 'returns true if even one term has a property', ->
      terms = [
        createTerm({lang: 'en', value: 'car'}),
        createTerm({lang: 'en', value: 'bus', properties: [{}]})
      ]
      result = view.hasTermProperties()
      expect(result).to.be.true

  describe '#setEditMode()', ->

    it 'sets editMode for view', ->
      view.setEditMode true
      expect(view.editMode).to.be.true

    it 'sets editMode for view and edit view for specific term', ->
      view.setEditMode true
      expect(view.editMode).to.be.true

  describe '#toggleEditTerm()', ->

    it 'always triggers termsChanged event', ->
      triggerStub = sinon.stub(view, 'trigger').withArgs('termsChanged')
      view.toggleEditTerm()
      expect(triggerStub).to.have.been.calledOnce

    context 'triggered by clicking on edit link', ->

      it 'sets the term to edit if not already edited', ->
        view.termToEdit = 1
        evt = $.Event 'click'
        evt.target = $ '<a data-id="2"></a>'
        view.toggleEditTerm(evt)
        expect(view.termToEdit).to.equal 2

      it 'sets the term to edit to false if already being edited', ->
        view.termToEdit = 2
        evt = $.Event 'click'
        evt.target = $ '<a data-id="2"></a>'
        view.toggleEditTerm(evt)
        expect(view.termToEdit).to.be.false

    context 'triggered by clicking on edit link', ->

      it 'sets the term to edit to false', ->
        view.termToEdit = 3
        view.toggleEditTerm()
        expect(view.termToEdit).to.be.false

  describe '#toggleProperties()', ->

    settingsStub = null

    beforeEach ->
      settingsStub = sinon.stub Coreon.application, 'repositorySettings'
      view.$el = $ '''
        <div class="terms">
          <div class="term">
            <div class="properties">
            </div>
          </div>
          <div class="term">
            <div class="properties">
            </div>
          </div>
        </div>
      '''
    afterEach ->
      Coreon.application.repositorySettings.restore

    it 'toggles the terms properties div up and down', ->
      view.toggleProperties()
      expect(view.$('.term .properties.collapsed')).to.have.lengthOf 2
      expect(settingsStub).to.have.been.calledWith('propertiesCollapsed', on)
      view.toggleProperties()
      expect(view.$('.term .properties.collapsed')).to.have.lengthOf 0
      expect(settingsStub).to.have.been.calledWith('propertiesCollapsed', off)

  describe '#toggleSection()', ->

    beforeEach ->
      view.$el = $ '''
        <div class="terms">
          <section class="collapsed"></section>
          <section class="collapsed"></section>
        </div>
      '''

    it 'toggles the language sections div up and down', ->
      evt = $.Event 'click'
      evt.target = view.$('section').first()
      view.toggleSection(evt)
      expect(view.$('section.collapsed')).to.have.lengthOf 1
      view.toggleSection(evt)
      expect(view.$('section.collapsed')).to.have.lengthOf 2

  describe '#addTerm()', ->

    newTerm = null
    termView = null
    termsChangedEvent = null

    beforeEach ->
      view.$el = $ '''
        <div class="terms">
          <div class="add">
            <a>Add new term</a>
          /div>
        </div>
      '''
      sinon.stub view, 'render'
      sinon.stub Coreon.Models, 'Term', ->
        newTerm = new Backbone.Model
        newTerm
      sinon.stub view, 'createTermView', ->
        termView = new Backbone.View
        sinon.stub termView, 'render', ->
          $el: $ '<div class="term"></div>'
        termView
      termsChangedEvent = sinon.stub(view, 'trigger').withArgs 'termToEditChanged'
      evt = ->
        target: view.$el.find('a')
      view.addTerm(evt)

    afterEach ->
      Coreon.Models.Term.restore()
      view.createTermView.restore()
      view.trigger.restore()

    it 'hides the add term button', ->
      expect(view.$el.find('.add')).to.not.be.visible

    it 'notifies the parent view that editing of terms stops', ->
      expect(termsChangedEvent).to.have.been.calledOnce

    it 'creates a new term model', ->
      expect(Coreon.Models.Term).to.have.been.calledOnce

    it 'sets the termToEdit property to point to that new model', ->
      expect(view.termToEdit).to.equal newTerm.id

    it 'creates a new view for the new term', ->
      expect(view.createTermView).to.have.been.called

    it 'listens to this views changes and triggers an event', ->
      view.trigger.restore()
      termsChanged = sinon.stub(view, 'trigger').withArgs 'termsChanged'
      termView.trigger 'created'
      expect(termsChanged).to.have.been.calledOnce

    it 'renders this term view', ->
      expect(view.$el).to.have '.term'










