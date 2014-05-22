#= require spec_helper
#= require views/terms/edit_terms_view

describe 'Coreon.Views.Terms.EditTermsView', ->

  template = null
  collection = null
  app = null
  view = null

  createCollection = ->
    collection = new Backbone.Collection
    collection.langs = -> []
    collection

  createApplication = ->
    app = new Backbone.Model langs: []
    app.langs = -> []
    app

  beforeEach ->
    template = @stub().returns ''
    collection = createCollection()
    app = createApplication()
    view = new Coreon.Views.Terms.EditTermsView
      template: template
      model: collection
      app: app

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'creates container', ->
    el = view.$el
    expect(el).to.have.class 'terms'
    expect(el).to.have.class 'edit'

  describe '#initialize()', ->

    context 'template', ->

      it 'assigns template from options', ->
        template2 = -> ''
        view.initialize template: template2
        assigned = view.template
        expect(assigned).to.equal template2

      it 'assigns default template when not given', ->
        template2 = @stub Coreon.Templates, 'terms/edit_terms'
        view.initialize()
        assigned = view.template
        expect(assigned).to.equal template2

    context 'app', ->

      app2 = null

      beforeEach ->
        app2 = createApplication()

      afterEach ->
        delete Coreon.application

      it 'assigns app from options', ->
        view.initialize app: app2
        assigned = view.app
        expect(assigned).to.equal app2

      it 'assigns default app when not given', ->
        Coreon.application = app2
        view.initialize()
        assigned = view.app
        expect(assigned).to.equal app2


  describe '#langs()', ->

    it 'delegates to module', ->
      expect(view.langs).to.equal Coreon.Modules.LanguageSections.langs

  describe '#render()', ->

    el = (view) ->
      view.$el

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    context 'template', ->

      langs = null

      beforeEach ->
        langs = @stub(view, 'langs')
          .returns []
        template.returns ''

      it 'wipes out old markup', ->
        view.$el.html '<ul class="old"></ul>'
        view.render()
        expect(el view).to.not.have '.old'

      it 'collects langs', ->
        collection.langs = -> ['en']
        app.langs = -> ['en', 'de', 'fr']
        app.set 'langs', [], silent: yes
        view.render()
        expect(langs).to.have.been.calledOnce
        expect(langs).to.have.been.calledWith ['en'], ['en', 'de', 'fr'], []

      it 'calls template', ->
        languages = [ id: 'en' ]
        langs.returns languages
        view.render()
        expect(template).to.have.been.calledOnce
        expect(template).to.have.been.calledWith languages: languages

      it 'inserts markup from template', ->
        template.returns '<section class="lang en"></section>'
        view.render()
        expect(el view).to.have 'section.lang.en'
