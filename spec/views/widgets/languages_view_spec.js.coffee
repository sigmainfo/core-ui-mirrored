#= require spec_helper
#= require views/widgets/languages_view

describe 'Coreon.Views.Widgets.LanguagesView', ->

  application = null
  model = null
  view = null

  beforeEach ->
    sinon.stub I18n, 't'
    sinon.stub jQuery.fn, 'coreonSelect'

    application = new Backbone.Model
    application.langs = sinon.stub()
    application.langs.returns []
    application.sourceLang = -> null
    application.targetLang = -> null
    d = $.Deferred()
    repo =
      getStats: ->
        d.promise()
    d.resolve()
    application.set 'repository', repo
    model = new Backbone.Model
    view = new Coreon.Views.Widgets.LanguagesView
      model: model
      app: application

  afterEach ->
    I18n.t.restore()
    jQuery.fn.coreonSelect.restore()

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'creates container', ->
    container = view.$el
    expect(container).to.match '#coreon-languages'
    expect(container).to.have.class 'widget'

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
          model: model
          app: application

      it 'is triggered on change of languages', ->
        application.trigger 'change:langs'
        expect(render).to.have.been.calledOnce
        expect(render).to.have.been.calledOn view

      it 'is triggered on change of repository', ->
        application.trigger 'change:repository'
        expect(render).to.have.been.calledOnce
        expect(render).to.have.been.calledOn view

      it 'is triggered on change of repository settings', ->
        application.trigger 'change:repositorySettings'
        expect(render).to.have.been.calledOnce
        expect(render).to.have.been.calledOn view

    it 'renders caption', ->
      I18n.t.withArgs('widgets.languages.title').returns 'Languages'
      view.render()
      caption = view.$('.titlebar h3')
      expect(caption).to.exist
      expect(caption).to.have.text 'Languages'

    it 'renders form', ->
      view.render()
      form = view.$('.content form')
      expect(form).to.exist
      expect(form).to.have.class 'languages'
      expect(form).to.have.attr 'action', 'javascript:void(0)'

    context 'source language', ->

      it 'renders select', ->
        view.render()
        select = view.$('form select[name="source_language"]')
        expect(select).to.exist
        expect(select).to.have.class 'widget-select'

      it 'renders option for no selection', ->
        I18n.t.withArgs('widgets.languages.none').returns '-- None'
        view.render()
        option = view.$('select[name="source_language"] option[value=""]')
        expect(option).to.exist

      it 'renders lang option', ->
        I18n.t.withArgs('languages.de').returns 'German'
        application.langs.withArgs(ignoreSelection: on).returns ['de']
        view.render()
        option = view.$('select[name="source_language"] option[value="de"]')
        expect(option).to.exist
        expect(option).to.have.text('DE German')

      it 'renders unknown lang option', ->
        I18n.t.withArgs('languages.de').returns 'German'
        application.langs.withArgs(ignoreSelection: on).returns ['de', 'foo']
        view.render()
        option = view.$('select[name="source_language"] option[value="foo"]')
        expect(option).to.exist
        expect(option).to.have.text('FOO')

      it 'marks source lang as being selected', ->
        application.langs.withArgs(ignoreSelection: on).returns ['de', 'en']
        application.sourceLang = -> 'en'
        view.render()
        de = view.$('select[name="source_language"] option[value="de"]')
        en = view.$('select[name="source_language"] option[value="en"]')
        expect(de).to.not.have.attr 'selected'
        expect(en).to.have.attr 'selected'

    context 'target language', ->

      it 'renders select', ->
        view.render()
        select = view.$('form select[name="target_language"]')
        expect(select).to.exist
        expect(select).to.have.class 'widget-select'

      it 'renders option for no selection', ->
        I18n.t.withArgs('widgets.languages.none').returns '-- None'
        view.render()
        option = view.$('select[name="target_language"] option[value=""]')
        expect(option).to.exist

      it 'renders lang option', ->
        I18n.t.withArgs('languages.de').returns 'German'
        application.langs.withArgs(ignoreSelection: on).returns ['de']
        view.render()
        option = view.$('select[name="target_language"] option[value="de"]')
        expect(option).to.exist
        expect(option).to.have.text('DE German')

      it 'renders unknown lang option', ->
        I18n.t.withArgs('languages.de').returns 'German'
        application.langs.withArgs(ignoreSelection: on).returns ['de', 'foo']
        view.render()
        option = view.$('select[name="target_language"] option[value="foo"]')
        expect(option).to.exist
        expect(option).to.have.text('FOO')

      it 'marks target lang as being selected', ->
        application.langs.withArgs(ignoreSelection: on).returns ['de', 'en']
        application.targetLang = -> 'en'
        view.render()
        de = view.$('select[name="target_language"] option[value="de"]')
        en = view.$('select[name="target_language"] option[value="en"]')
        expect(de).to.not.have.attr 'selected'
        expect(en).to.have.attr 'selected'

    it 'transforms rendered selects into custom components', ->
      transform = sinon.spy()
      sinon.stub view, '$'
      view.$.withArgs('select').returns coreonSelect: transform
      view.render()
      expect(transform).to.have.been.calledOnce

  describe '#updateSource()', ->

    event = null
    select = null
    settings = null

    beforeEach ->
      settings = sinon.spy()
      application.repositorySettings = settings
      view.$el.html '''
        <select name="source_language">
          <option value="">-- None</option>
          <option value="de">DE German</option>
        </select>
      '''
      select = view.$('select')
      event = $.Event 'change'
      event.target = select[0]

    it 'is triggered on selection change', ->
      updateSource = sinon.spy()
      view.updateSource = updateSource
      view.delegateEvents()
      select.trigger 'change'
      expect(updateSource).to.have.been.calledOnce
      expect(updateSource).to.have.been.calledOn view

    it 'updates source language from value', ->
      option = view.$('select option[value="de"]')
      option.prop 'selected', on
      select.trigger event
      expect(settings).to.have.been.calledOnce
      expect(settings).to.have.been.calledWith 'sourceLanguage', 'de'

    it 'nullifies source language for empty value', ->
      option = view.$('select option[value=""]')
      option.prop 'selected', on
      select.trigger event
      expect(settings).to.have.been.calledOnce
      expect(settings).to.have.been.calledWith 'sourceLanguage', null

  describe '#updateTarget()', ->

    event = null
    select = null
    settings = null

    beforeEach ->
      settings = sinon.spy()
      application.repositorySettings = settings
      view.$el.html '''
        <select name="target_language">
          <option value="">-- None</option>
          <option value="de">DE German</option>
        </select>
      '''
      select = view.$('select')
      event = $.Event 'change'
      event.target = select[0]

    it 'is triggered on selection change', ->
      updateTarget = sinon.spy()
      view.updateTarget = updateTarget
      view.delegateEvents()
      select.trigger 'change'
      expect(updateTarget).to.have.been.calledOnce
      expect(updateTarget).to.have.been.calledOn view

    it 'updates target language from value', ->
      option = view.$('select option[value="de"]')
      option.prop 'selected', on
      select.trigger event
      expect(settings).to.have.been.calledOnce
      expect(settings).to.have.been.calledWith 'targetLanguage', 'de'

    it 'nullifies target language for empty value', ->
      option = view.$('select option[value=""]')
      option.prop 'selected', on
      select.trigger event
      expect(settings).to.have.been.calledOnce
      expect(settings).to.have.been.calledWith 'targetLanguage', null
