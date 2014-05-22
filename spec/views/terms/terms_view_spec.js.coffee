#= require spec_helper
#= require views/terms/terms_view

describe 'Coreon.Views.Terms.TermsView', ->

  view = null
  collection = null
  app = null

  beforeEach ->
    termView = new Backbone.View
    @stub Coreon.Views.Terms, 'TermView'
    Coreon.Views.Terms.TermView.returns termView

    app = new Backbone.Model langs: []
    app.langs = -> []

    collection = new Backbone.Collection
    collection.langs = -> []

    view = new Coreon.Views.Terms.TermsView
      model: collection
      app: app

  buildTerm = (attrs = {}) ->
    _(attrs).defaults properties: []
    term = new Backbone.Model attrs

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'creates container', ->
    el = view.$el
    expect(el).to.have.class 'terms'
    expect(el).to.have.class 'show'

  describe '#initialize()', ->

    it 'sets app from options', ->
      app2 = new Backbone.Model
      view.initialize app: app2
      assigned = view.app
      expect(assigned).to.equal app2

    it 'defaults app to singleton instance', ->
      app2 = new Backbone.Model
      Coreon.application = app2
      try
        view.initialize()
        assigned = view.app
        expect(assigned).to.equal app2
      finally
        delete Coreon.application

    it 'sets template from options', ->
      template = ->
      view.initialize template: template
      assigned = view.template
      expect(assigned).to.equal template

    it 'defaults template to be terms/terms', ->
      view.initialize()
      assigned = view.template
      expect(assigned).to.equal Coreon.Templates['terms/terms']

    it 'creates empty subviews set', ->
      subviews = view.subviews
      expect(subviews).to.exist

  describe '#langs()', ->

    it 'delegates to module', ->
      expect(view.langs).to.equal Coreon.Modules.LanguageSections.langs

  describe '#render()', ->

    template = null

    el = (view) ->
      view.$el

    beforeEach ->
      template = @stub view, 'template'
      app.set 'langs', [], silent: yes
      collection.reset [], silent: yes
      collection.langs = -> []

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    it 'clears subviews', ->
      remove = @spy()
      subview = remove: remove
      view.subviews = [subview]
      view.render()
      expect(remove).to.have.been.calledOnce
      subviews = view.subviews
      expect(subviews).to.be.empty

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

    context 'terms', ->

      term = null
      subview = null

      beforeEach ->
        term = buildTerm()
        collection.reset [term], silent: yes
        subview = new Backbone.View
        constructor = Coreon.Views.Terms.TermView
        constructor.returns subview

      it 'creates subview for each term', ->
        constructor = Coreon.Views.Terms.TermView
        view.render()
        expect(constructor).to.have.been.calledOnce
        expect(constructor).to.have.been.calledWithNew
        expect(constructor).to.have.been.calledWith
          model: term

      it 'renders subview', ->
        render = @stub()
        subview.render = render
        view.render()
        expect(render).to.have.been.calledOnce

      it 'appends subview to language section', ->
        view.$el.html '''
          <section class="language" data-id="de-AT">
            <ul></ul>
          </section>
        '''
        term.set 'lang', 'de-AT', silent: yes
        view.render()
        ul = view.$('ul')[0]
        el = subview.el
        expect($.contains ul, el).to.be.true

      it 'keeps reference to subview', ->
        view.render()
        subviews = view.subviews
        expect(subviews).to.include subview

      it 'collapses all propery sections', ->
        $('#konacha').append view.$el
        view.$el.html '''
          <section class="properties">
            <h3>Toggle Properties</h3>
            <div>
              <p>foo</p>
            </div>
          </section>
        '''
        view.render()
        properties = view.$('.properties')
        expect(properties).to.have.class 'collapsed'
        container = properties.children('div')
        expect(container).to.be.hidden

    context 'properties toggle', ->

      term = null

      beforeEach ->
        term = buildTerm()
        collection.reset [term], silent: yes
        template.returns '<a class="toggle-all-properties" href="#">toggle</a>'
        view.$el.appendTo 'body'

      toggle = (view) ->
        view.$ '.toggle-all-properties'

      it 'keeps toggle visible when there are term properties', ->
        term.set 'properties', [key: 'label', value: 'gun'], silent: yes
        view.render()
        expect(toggle view).to.be.visible

      it 'hides toggle when there are no term properties', ->
        term.set 'properties', {}, silent: yes
        view.render()
        expect(toggle view).to.be.hidden

  describe '#toggleAllProperties()', ->

    toggle = null
    event = null

    beforeEach ->
      view.$el.html '''
        <h4 class="toggle-all-properties">Toggle all properties</h4>
        <ul>
          <li class="term">
            <section class="properties collapsed">
              <h3>Toggle Properties</h3>
              <div>foo</div>
            </section>
          </li>
          <li class="term">
            <section class="properties collapsed">
              <h3>Toggle Properties</h3>
              <div>bar</div>
            </section>
          </li>
        </ul>
      '''
      $('#konacha').append view.$el
      toggle = view.$('.toggle-all-properties')
      event = $.Event 'click'
      event.target = toggle.el

    it 'is triggered by click on toggle', ->
      toggleAllProperties = @spy()
      view.toggleAllProperties = toggleAllProperties
      view.delegateEvents()
      toggle.trigger event
      expect(toggleAllProperties).to.have.been.calledOnce
      expect(toggleAllProperties).to.have.been.calledWith event
      expect(toggleAllProperties).to.have.been.calledOn view

    it 'eats event', ->
      toggle.trigger event
      defaultPrevented = event.isDefaultPrevented()
      expect(defaultPrevented).to.be.true
      propagationStopped = event.isPropagationStopped()
      expect(propagationStopped).to.be.true

    it 'expands all properties', ->
      toggle.trigger event
      view.$('.properties').each ->
        properties = $ @
        expect(properties).to.not.have.class 'collapsed'
        container = properties.children('div')
        expect(container).to.be.visible

    it 'collapses properties when all are already expanded', ->
      view.$('.collapsed').removeClass 'collapsed'
      toggle.trigger event
      view.$('.properties').each ->
        properties = $ @
        expect(properties).to.have.class 'collapsed'
        container = properties.children('div')
        expect(container).to.be.hidden
