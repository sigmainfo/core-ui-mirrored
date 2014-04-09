#= require spec_helper
#= require views/terms/terms_view

describe 'Coreon.Views.Terms.TermsView', ->

  view = null
  collection = null
  app = null

  beforeEach ->
    sinon.stub I18n, 't'
    termView = new Backbone.View
    sinon.stub Coreon.Views.Terms, 'TermView'
    Coreon.Views.Terms.TermView.returns termView

    app = new Backbone.Model langs: []
    app.langs = -> []

    collection = new Backbone.Collection
    collection.langs = -> []
    collection.hasProperties = -> no

    view = new Coreon.Views.Terms.TermsView
      model: collection
      app: app

  afterEach ->
    I18n.t.restore()
    Coreon.Views.Terms.TermView.restore()

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'creates container', ->
    el = view.$el
    expect(el).to.have.class 'terms'

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
      template = sinon.stub()
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
      remove = sinon.spy()
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
        render = sinon.stub()
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
