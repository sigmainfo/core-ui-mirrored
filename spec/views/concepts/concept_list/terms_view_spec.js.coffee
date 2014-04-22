#= require spec_helper
#= require views/concepts/concept_list/terms_view

describe 'Coreon.Views.Concepts.ConceptList.TermsView', ->

  view = null
  concept = null
  app = null

  beforeEach ->
    app = new Backbone.Model langs: []
    app.lang = -> 'en'
    concept = new Backbone.Model
    concept.termsByLang = -> {}
    view = new Coreon.Views.Concepts.ConceptList.TermsView
      model: concept
    , app: app

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'creates container', ->
    container = view.$el
    expect(container).to.match 'tbody'

  describe '#initialize()', ->

    it 'assigns app', ->
      assigned = view.app
      expect(assigned).to.equal app

  describe '#render()', ->

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    context 'triggers', ->

      render = null

      beforeEach ->
        render = sinon.spy()
        view.render = render
        view.initialize
          model: concept
        , app: app

      it 'is triggered on terms changes', ->
        concept.trigger 'change:terms'
        expect(render).to.have.been.calledOnce
        expect(render).to.have.been.calledOn view

      it 'is triggered on langs changes', ->
        app.trigger 'change:langs'
        expect(render).to.have.been.calledOnce
        expect(render).to.have.been.calledOn view

    context 'markup', ->

      it 'renders a section per language', ->
        app.set 'langs', ['en', 'de'], silent: yes
        view.render()
        rows = view.$('tr.lang')
        expect(rows).to.have.lengthOf 2

      it 'adds lang name as class to section', ->
        app.set 'langs', ['hu'], silent: yes
        view.render()
        rows = view.$('tr.lang')
        expect(rows).to.have.class 'hu'

      it 'renders label for lang', ->
        app.set 'langs', ['hu'], silent: yes
        view.render()
        label = view.$('tr.lang th')
        expect(label).to.exist
        expect(label).to.have.text 'hu'

      it 'renders term for lang', ->
        concept.termsByLang = ->
          hu: [new Backbone.Model value: 'mordály']
        app.set 'langs', ['hu'], silent: yes
        view.render()
        label = view.$('tr.lang td')
        expect(label).to.exist
        expect(label).to.have.text 'mordály'

      it 'renders empty cell when no terms are given', ->
        concept.termsByLang = -> {}
        app.set 'langs', ['hu'], silent: yes
        view.render()
        label = view.$('tr.lang td')
        expect(label).to.exist
        expect(label).to.be.empty

      it 'renders delimiers between terms', ->
        concept.termsByLang = ->
          hu: ['mordály', 'fegyver'].map (value) ->
            new Backbone.Model value: value
        app.set 'langs', ['hu'], silent: yes
        view.render()
        delimiter = view.$('tr.lang td span')
        expect(delimiter).to.have.lengthOf 1
        expect(delimiter).to.have.text ' | '

      it 'falls back to display lang when no lang is currently selected', ->
        app.set 'langs', [], silent: yes
        app.lang = -> 'en'
        concept.termsByLang = ->
          en: [new Backbone.Model value: 'gun']
        view.render()
        label = view.$('tr.lang th')
        expect(label).to.have.text 'en'
        label = view.$('tr.lang td')
        expect(label).to.have.text 'gun'
