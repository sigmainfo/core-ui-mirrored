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
    collection.hasProperties = -> no

    view = new Coreon.Views.Terms.TermsView
      model: collection
      app: app

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

  describe '#render()', ->

    template = null

    beforeEach ->
      template = @stub()
      view.template = template
      app.set 'langs', [], silent: yes
      collection.reset [], silent: yes
      collection.langs = -> []

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    it 'updates content via template', ->
      view.$el.html '<ul class="old"></ul>'
      template.withArgs(
        languages: []
        hasProperties: no
      ).returns '<ul class="terms"></ul>'
      view.render()
      updated = view.$('ul.terms')
      expect(updated).to.exist
      old = view.$('ul.old')
      expect(old).to.not.exist

    it 'clears subviews', ->
      remove = @spy()
      subview = remove: remove
      view.subviews = [subview]
      view.render()
      expect(remove).to.have.been.calledOnce
      subviews = view.subviews
      expect(subviews).to.be.empty

    context 'languages', ->

      it 'creates language groups from used langs', ->
        collection.langs = -> ['de']
        view.render()
        expect(template).to.have.been.calledOnce
        languages = template.firstCall.args[0].languages
        expect(languages).eql [id: 'de', className: 'de', empty: no]

      it 'unifies class name', ->
        collection.langs = -> ['DE-AT']
        view.render()
        expect(template).to.have.been.calledOnce
        language = template.firstCall.args[0].languages[0]
        expect(language).to.have.property 'className', 'de'
        expect(language).to.have.property 'id', 'DE-AT'

      it 'sorts language groups by available language order', ->
        app.langs = -> ['fr', 'hu', 'de']
        collection.langs = -> ['hu', 'de', 'fr']
        view.render()
        expect(template).to.have.been.calledOnce
        langs = template.firstCall.args[0].languages.map (language) ->
          language.id
        expect(langs).eql ['fr', 'hu', 'de']

      it 'appends language groups for unknown langs', ->
        app.langs = -> ['fr']
        collection.langs = -> ['hu', 'fr']
        view.render()
        expect(template).to.have.been.calledOnce
        langs = template.firstCall.args[0].languages.map (language) ->
          language.id
        expect(langs).eql ['fr', 'hu']

      it 'prepends language groups for selection', ->
        app.langs = -> ['fr', 'hu', 'de']
        app.set 'langs', ['de', 'hu']
        collection.langs = -> ['hu', 'de', 'fr']
        view.render()
        expect(template).to.have.been.calledOnce
        langs = template.firstCall.args[0].languages.map (language) ->
          language.id
        expect(langs).eql ['de', 'hu', 'fr']

      it 'prepends selected languages even when not present', ->
        app.langs = -> ['fr', 'hu', 'de']
        app.set 'langs', ['de', 'hu'], silent: yes
        collection.langs = -> ['hu', 'el']
        view.render()
        expect(template).to.have.been.calledOnce
        langs = template.firstCall.args[0].languages.map (language) ->
          language.id
        expect(langs).eql ['de', 'hu', 'el']

      it 'marks empty language groups', ->
        app.set 'langs', ['de'], silent: yes
        collection.langs -> []
        view.render()
        language = template.firstCall.args[0].languages[0]
        expect(language).to.have.property 'empty', yes

    context 'hasProperties', ->

      it 'is false when there are no properties on any term', ->
        collection.hasProperties = -> no
        view.render()
        expect(template).to.have.been.calledOnce
        data = template.firstCall.args[0]
        expect(data).to.have.property 'hasProperties', no

      it 'is true when there are properties on any term', ->
        collection.hasProperties = -> yes
        view.render()
        expect(template).to.have.been.calledOnce
        data = template.firstCall.args[0]
        expect(data).to.have.property 'hasProperties', yes

    context 'terms', ->

      term = null
      subview = null

      beforeEach ->
        collection.reset [lang: 'de', value: 'Schuh']
        [term] = collection.models
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

  describe '#toggleAllProperties()', ->

    toggle = null
    event = null

    beforeEach ->
      view.$el.html '''
        <h4 class="properties-toggle">Toggle all properties</h4>
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
      toggle = view.$('.properties-toggle')
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
