#= require spec_helper
#= require views/terms/terms_view

describe 'Coreon.Views.Terms.TermsView', ->

  view = null
  collection = null
  app = null

  beforeEach ->
    sinon.stub I18n, 't'

    app = new Backbone.Model
    app.langs = -> []

    collection = new Backbone.Collection
    collection.byLang = -> []

    view = new Coreon.Views.Terms.TermsView
      model: collection
      app: app

  afterEach ->
    I18n.t.restore()

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

    it 'defaults to global application', ->
      app2 = new Backbone.Model
      Coreon.application = app2
      try
        view.initialize()
        assigned = view.app
        expect(assigned).to.equal app2
      finally
        delete Coreon.application

  describe '#render()', ->

    term = null

    createTerm = (attrs) ->
      term = new Backbone.Model attrs
      term.info = -> {}
      term.propertiesByKey = -> []
      term

    beforeEach ->
      term = createTerm()

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    context 'properties toggle', ->

      beforeEach ->
        collection.reset [term], silent: yes

      it 'renders toggle all switch', ->
        I18n.t.withArgs('terms.properties.toggle-all').returns 'Toggle all'
        term.propertiesByKey = -> [ key: 'source', properties: [] ]
        view.render()
        toggle = view.$('h4.properties-toggle')
        expect(toggle).to.exist
        expect(toggle).to.have.attr 'title', 'Toggle all'
        text = toggle.text()
        expect(text).to.match /\s*Toggle all\s*/

      it 'does not render switch when there are no properties', ->
        term.propertiesByKey = -> []
        view.render()
        toggle = view.$('h4.properties-toggle')
        expect(toggle).to.not.exist


    context 'language sections', ->


      beforeEach ->
        view.app.set 'langs', [], silent: yes

      it 'renders section containers', ->
        view.app.langs = -> ['de', 'en']
        byLang = sinon.stub()
        collection.byLang = byLang
        byLang.withArgs('de', 'en').returns [
          {id: 'de', terms: [term]}
          {id: 'en', terms: [term]}
        ]
        view.render()
        languages = view.$('section.language')
        expect(languages).to.have.lengthOf 2

      it 'classifies section', ->
        collection.byLang = ->
          [ id: 'de', terms: [term] ]
        view.render()
        language = view.$('.language')
        expect(language).to.have.class 'de'

      it 'abbreviates class name', ->
        collection.byLang = ->
          [ id: 'de-AT', terms: [term] ]
        view.render()
        language = view.$('.language')
        expect(language).to.have.class 'de'

      it 'renders caption', ->
        collection.byLang = ->
          [ id: 'de-AT', terms: [term] ]
        view.render()
        caption = view.$('.language h3')
        expect(caption).to.have.text 'de-AT'

      context 'empty section', ->

        it 'renders empty list when selected', ->
          view.app.set 'langs', ['de'], silent: yes
          I18n.t.withArgs('terms.empty').returns '[no terms]'
          collection.byLang = ->
            [ id: 'de', terms: [] ]
          view.render()
          terms = view.$('.language ul li')
          expect(terms).to.have.lengthOf 1
          expect(terms).to.have.class 'no-terms'
          expect(terms).to.have.text '[no terms]'

        it 'renders nothing', ->
          view.app.set 'langs', [], silent: yes
          collection.byLang = ->
            [ id: 'de', terms: [] ]
          view.render()
          terms = view.$('.language')
          expect(terms).to.not.exist

      context 'with terms', ->

        it 'renders term containers', ->
          term1 = createTerm()
          term2 = createTerm()
          collection.byLang = ->
            [ id: 'hu', terms: [term1, term2] ]
          view.render()
          terms = view.$('.language ul li')
          expect(terms).to.have.lengthOf 2
          expect(terms).to.have.class 'term'

        it 'renders term value', ->
          term = createTerm value: 'handgun'
          collection.byLang = ->
            [ id: 'en', terms: [term] ]
          view.render()
          value = view.$('.language ul li.term > h4.value')
          expect(value).to.exist
          expect(value).to.have.text 'handgun'

        context 'system info', ->

          term = null

          beforeEach ->
            term = createTerm value: 'handgun'
            collection.byLang = ->
              [ id: 'en', terms: [term] ]

          it 'renders table', ->
            term.info = -> {}
            view.render()
            info = view.$('li.term .system-info table')
            expect(info).to.exist

          it 'renders data', ->
            term.info = ->
              import_id: '123'
            view.render()
            label = view.$('.system-info table tr th')
            expect(label).to.have.lengthOf 1
            expect(label).to.have.text 'import_id'
            value = view.$('.system-info tr td')
            expect(value).to.have.lengthOf 1
            expect(value).to.have.text '123'

          it 'renders placeholder for empty value', ->
            term.info = ->
              import_id: null
            view.render()
            value = view.$('.system-info table tr td')
            expect(value).to.have.text '-'

        context 'no properties', ->

          term = null


          beforeEach ->
            term = createTerm value: 'gun'
            term.propertiesByKey = -> []
            collection.byLang = ->
              [ id: 'en', terms: [term] ]

          it 'does not render section', ->
            view.render()
            section = view.$('section.properties')
            expect(section).to.not.exist

        context 'properties', ->

          term = null
          property = null

          createProperty = (attrs) ->
            property = new Backbone.Model attrs
            property.info = -> {}
            property

          beforeEach ->
            term = createTerm value: 'gun'
            property = createProperty key: 'author', value: 'Nobody'
            term.propertiesByKey = -> [
              key: property.get('key')
              properties: [property]
            ]
            collection.byLang = ->
              [ id: 'en', terms: [term] ]

          it 'renders section', ->
            view.render()
            section = view.$('section.properties')
            expect(section).to.exist

          it 'renders caption', ->
            I18n.t.withArgs('properties.title').returns 'Properties'
            I18n.t.withArgs('properties.toggle').returns 'Toggle properties'
            view.render()
            caption = view.$('.properties h3')
            expect(caption).to.exist
            expect(caption).to.have.text 'Properties'
            expect(caption).to.have.attr 'title', 'Toggle properties'

          it 'renders table', ->
            view.render()
            table = view.$('.properties div table')
            expect(table).to.exist

          it 'collapses section by default', ->
            view.render()
            section = view.$('section.properties')
            expect(section).to.have.class 'collapsed'
            content = section.children('div')
            expect(content).to.have.css 'display', 'none'

          it 'renders row for property group', ->
            property.set
              key: 'source'
              value: 'common sense'
            , silent: yes
            view.render()
            row = view.$('.properties table tr')
            expect(row).to.exist
            th = row.find('th')
            expect(th).to.exist
            expect(th).to.have.text 'source'
            td = row.find('td')
            expect(td).to.exist

          context 'single non-textual property', ->

            beforeEach ->
              property.set
                key: 'abbreviation'
                value: 'CRN'
                lang: ''
              , silent: yes
              term.propertiesByKey = -> [
                key: 'abbreviation'
                properties: [property]
              ]

            it 'renders plain value', ->
              view.render()
              td = view.$('.properties tr td')
              value = td.find('.value')
              expect(value).to.exist
              expect(value).to.have.text 'CRN'

            it 'does not render index', ->
              view.render()
              td = view.$('.properties tr td')
              index = td.find('.index')
              expect(index).to.not.exist

            it 'renders system info', ->
              property.info = -> import_id: '1234'
              view.render()
              td = view.$('.properties tr td')
              info = td.find('.system-info table')
              expect(info).to.exist
              label = info.find('tr th')
              expect(label).to.exist
              expect(label).to.have.text 'import_id'
              value = info.find('tr td')
              expect(value).to.exist
              expect(value).to.have.text '1234'

          context 'single textual property', ->

            beforeEach ->
              property.set
                key: 'description'
                value: 'It is what it is.'
                lang: 'en'
              , silent: yes
              term.propertiesByKey = -> [
                key: 'description'
                properties: [property]
              ]

            it 'renders value as list item', ->
              property.set 'value', 'a rose', silent: yes
              view.render()
              td = view.$('.properties tr td')
              item = td.find('ul.values li')
              value = item.find('.value')
              expect(value).to.exist
              expect(value).to.have.text 'a rose'

            it 'renders index', ->
              property.set 'lang', 'hu', silent: yes
              view.render()
              td = view.$('.properties tr td')
              index = td.find('ul.index li')
              expect(index).to.exist
              expect(index).to.have.text 'hu'
              expect(index).to.have.class 'selected'
              expect(index).to.have.attr 'data-index', '0'

            it 'renders system info', ->
              property.info = -> import_id: '1234'
              view.render()
              td = view.$('.properties tr td')
              item = td.find('ul.values li')
              info = item.find('.system-info table')
              expect(info).to.exist
              label = info.find('tr th')
              expect(label).to.exist
              expect(label).to.have.text 'import_id'
              value = info.find('tr td')
              expect(value).to.exist
              expect(value).to.have.text '1234'

          context 'multiple properties', ->

            property2 = null

            beforeEach ->
              property2 = createProperty key: 'source', value: 'Wikipedia'
              term.propertiesByKey = -> [
                key: 'description'
                properties: [property, property2]
              ]

            it 'renders value as list item', ->
              property2.set 'value', 'a rose', silent: yes
              view.render()
              td = view.$('.properties tr td')
              item = td.find('ul.values li:nth-child(2)')
              value = item.find('.value')
              expect(value).to.exist
              expect(value).to.have.text 'a rose'

            it 'renders numerical index', ->
              property.set 'lang', null, silent: yes
              view.render()
              td = view.$('.properties tr td')
              index = td.find('ul.index li:nth-child(2)')
              expect(index).to.exist
              expect(index).to.have.text '2'
              expect(index).to.have.attr 'data-index', '1'

            it 'renders language index', ->
              property.set 'lang', 'de', silent: yes
              view.render()
              td = view.$('.properties tr td')
              index = td.find('ul.index li:nth-child(2)')
              expect(index).to.exist
              expect(index).to.have.text 'de'
              expect(index).to.have.attr 'data-index', '1'

            it 'selects first item of index', ->
              view.render()
              td = view.$('.properties tr td')
              items = td.find('ul.index li')
              first = items.eq(0)
              expect(first).to.have.class 'selected'
              other = items.eq(1)
              expect(other).to.not.have.class 'selected'

            it 'selects first item of values', ->
              view.render()
              td = view.$('.properties tr td')
              items = td.find('ul.values li')
              first = items.eq(0)
              expect(first).to.have.class 'selected'
              other = items.eq(1)
              expect(other).to.not.have.class 'selected'

            it 'renders system info', ->
              property2.info = -> import_id: '1234'
              view.render()
              td = view.$('.properties tr td')
              item = td.find('ul.values li:nth-child(2)')
              info = item.find('.system-info table')
              expect(info).to.exist
              label = info.find('tr th')
              expect(label).to.exist
              expect(label).to.have.text 'import_id'
              value = info.find('tr td')
              expect(value).to.exist
              expect(value).to.have.text '1234'
