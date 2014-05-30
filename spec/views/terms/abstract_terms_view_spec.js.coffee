#= require spec_helper
#= require views/terms/abstract_terms_view

describe 'Coreon.Views.Terms.AbstractTermsView', ->

  view = null
  collection = null
  app = null
  template = null

  fakeApplication = ->
    app = new Backbone.Model langs: []
    app.langs = -> []
    app

  fakeCollection = ->
    collection = new Backbone.Collection
    collection.langs = -> []
    collection

  beforeEach ->
    app = fakeApplication()
    collection = fakeCollection()
    template = @stub().returns ''

    view = new Coreon.Views.Terms.AbstractTermsView
      model: collection
      app: app
      template: template

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceOf Coreon.Views.CompositeView

  it 'creates container', ->
    el = view.$el
    expect(el).to.have.class 'terms'

  describe '#initialize()', ->

    afterEach ->
      delete Coreon.application

    it 'assigns template from options', ->
      template2 = -> ''
      view.initialize template: template2
      expect(view.template).to.equal template2

    it 'assigns app from options', ->
      app2 = fakeApplication()
      view.initialize app: app2
      expect(view.app).to.equal app2

    it 'defaults app to global reference', ->
      app2 = fakeApplication()
      Coreon.application = app2
      view.initialize()
      expect(view.app).to.equal app2

  describe '#render()', ->

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    context 'template', ->

      el = (view) ->
        view.$el

      it 'wipes out old markup', ->
        view.$el.html '<div class="old">remove me</div>'
        view.render()
        expect(el view).to.not.have '.old'

      it 'renders markup via template', ->
        languages = [ id: 'el' ]
        view.languageSections = -> languages
        view.render()
        expect(template).to.have.been.calledOnce
        expect(template).to.have.been.calledWith languages: languages

      it 'inserts rendered markup', ->
        template.returns '<section class="language el"></section>'
        view.render()
        expect(el view).to.have 'section.language.el'

    describe 'terms', ->

      renderSubviews = null

      beforeEach ->
        renderSubviews = @spy view, 'renderSubviews'

      it 'renders subviews', ->
        view.render()
        expect(renderSubviews).to.have.been.calledOnce

      it 'renders subviews into new markup', ->
        view.render()
        expect(renderSubviews).to.have.been.calledAfter template

    describe 'properties', ->

      beforeEach ->
        template.returns '''
          <div class="properties">
            <h3>PROPERTIES</h3>
            <div class="edit"></div>
            <div></div>
          </div>
        '''
        view.$el.appendTo 'body'

      properties = (view) ->
        view.$ '.properties'

      content = (view) ->
        properties(view).find('div:not(.edit)')

      it 'collapses all properties', ->
        view.render()
        expect(properties view).to.have.class 'collapsed'

      it 'immediately hides content of properties', ->
        view.render()
        content = properties(view).find 'div:not(.edit)'
        expect(content).to.be.hidden

      it 'does not hide caption', ->
        view.render()
        caption = properties(view).find 'h3'
        expect(caption).to.be.visible

      it 'does not hide edit form', ->
        view.render()
        edit = properties(view).find '.edit'
        expect(edit).to.be.visible

  describe '#insertSubview()', ->

    fakeTerm = (attrs) ->
      get: (key) -> attrs[key]

    fakeSubview = (model) ->
      el: $('<div>')
      model: model

    it 'appends subview to corresponding language section', ->
      view.$el.html '''
        <section class="language" data-id="en"></section>
        <section class="language" data-id="de"></section>
      '''
      model = fakeTerm lang: 'de'
      subview = fakeSubview model
      view.insertSubview subview
      section = view.$ 'section[data-id="de"]'
      expect(subview.el).to.be.childOf section

  describe '#toggleAllProperties()', ->

    properties = null

    fakeProperties = (view) ->
      $('<div class="properties"></div>').appendTo view.el

    beforeEach ->
      properties = fakeProperties view
      view.$el.appendTo 'body'

    context 'triggers', ->

      toggleAllProperties = null

      fakeToggle = (view) ->
        $('<a class="toggle-all-properties">toggle</a>').appendTo view.el

      beforeEach ->
        toggleAllProperties = @spy view, 'toggleAllProperties'
        view.delegateEvents()

      it 'is triggered by click on toggle', ->
        toggle = fakeToggle view
        toggle.click()
        expect(toggleAllProperties).to.have.been.calledOnce

    context 'expanded', ->

      it 'collapses properties', ->
        view.toggleAllProperties()
        expect(properties).to.have.class 'collapsed'

      it 'hides content of properties', ->
        content = $('<div>').appendTo properties
        view.toggleAllProperties()
        expect(content).to.be.hidden

      it 'does not hide caption', ->
        caption = $('<h3>PROPERTIES</h3>').appendTo properties
        view.toggleAllProperties()
        expect(caption).to.be.visible

      it 'does not hide edit forms', ->
        edit = $('<div class="edit">').appendTo properties
        view.toggleAllProperties()
        expect(edit).to.be.visible

    context 'collapsed', ->

      beforeEach ->
        properties.addClass 'collapsed'

      it 'expands properties', ->
        view.toggleAllProperties()
        expect(properties).to.not.have.class 'collapsed'

      it 'expands all properties when partially collapsed', ->
        properties2 = fakeProperties view
        view.toggleAllProperties()
        expect(properties).to.not.have.class 'collapsed'
        expect(properties2).to.not.have.class 'collapsed'

      it 'reveals content of properties', ->
        content = $('<div>').hide().appendTo properties
        view.toggleAllProperties()
        expect(content).to.be.visible
