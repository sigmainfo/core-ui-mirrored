#= require spec_helper
#= require views/panels/terms/term_list_view
#= require helpers/can

describe 'Coreon.Views.Panels.Terms.TermListView', ->

  view = null
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
    terms = {}
    view = new Coreon.Views.Panels.Terms.TermListView model: terms

  afterEach ->
    Coreon.Helpers.can.restore()

  it 'is a backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'has a container', ->
    el = view.$el
    expect(el).to.have.class 'terms'

  it 'accepts a collection of terms grouped by language', ->
    expect(view.model).to.be.instanceof Object

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
      terms.en = [createTerm({value: 'test', properties: [{}]})]
      el = view.render().$el
      expect(el).to.have 'h4.properties-toggle'

    it 'renders and add term link', ->
      el = view.render().$el
      expect(el).to.have 'a.add-term'

    it 'renders sections of grouped terms', ->
      terms.en = [createTerm({value: 'car'})]
      terms.de = [createTerm({value: 'auto'})]
      el = view.render().$el
      sections = view.$('section.language')
      expect(sections).to.have.lengthOf 2
      expect(sections.first()).to.contain 'en'
      expect(sections.last()).to.contain 'de'

    it 'renders "terms empty" message for group with no terms', ->
      sinon.stub(I18n, 't').withArgs('terms.empty').returns 'empty'
      terms.de = []
      el = view.render().$el
      section = view.$('section.language').first()
      expect(section).to.contain 'empty'

    it 'renders terms for each language group', ->
      terms.en = [createTerm({value: 'car'})]
      terms.de = [createTerm({value: 'auto'})]
      el = view.render().$el
      expect(Coreon.Views.Panels.Terms.TermView).to.have.been.calledTwice

    it 'renders terms in edit mode if term is being edited', ->
      terms.en = [createTerm({id: 1, value: 'car'})]
      terms.de = [createTerm({id: 2, value: 'auto'})]
      view.setEditMode true, 2
      el = view.render().$el
      expect(Coreon.Views.Panels.Terms.TermView).to.have.been.calledOnce
      expect(Coreon.Views.Panels.Terms.EditTermView).to.have.been.calledOnce

  describe '#hasTermProperties()', ->

    it 'returns false if no term has even one property', ->
      terms.en = [createTerm(value: 'car')]
      result = view.hasTermProperties()
      expect(result).to.be.false

    it 'returns true if even one term has a property', ->
      terms.en = [createTerm(value: 'car'), createTerm(value: 'bus', properties: [{}])]
      result = view.hasTermProperties()
      expect(result).to.be.true

  describe '#setEditMode()', ->

    it 'sets editMode for view', ->
      view.setEditMode true
      expect(view.editMode).to.be.true

    it 'sets editMode for view and edit view for specific term', ->
      view.setEditMode true, 1
      expect(view.editMode).to.be.true
      expect(view.termToEdit).to.be.equal 1





