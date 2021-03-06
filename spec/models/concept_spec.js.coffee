#= require spec_helper
#= require models/concept
#= require models/repository_settings

describe 'Coreon.Models.Concept', ->

  beforeEach ->
    @hits = new Backbone.Collection
    @hits.findByResult = -> null
    sinon.stub Coreon.Collections.Hits, 'collection', => @hits
    @model = new Coreon.Models.Concept id: '123'

  afterEach ->
    Coreon.Collections.Hits.collection.restore()

  it 'is a Backbone model', ->
    expect( @model ).to.been.an.instanceof Backbone.Model

  it 'is an accumulating model', ->
    expect( Coreon.Models.Concept.find ).to.equal Coreon.Modules.Accumulation.find

  it 'uses Concepts collection for accumulation', ->
    collection = Coreon.Models.Concept.collection()
    expect( collection ).to.be.an.instanceof Coreon.Collections.Concepts
    expect( Coreon.Models.Concept.collection() ).to.equal collection

  it 'has an URL root', ->
    expect( @model.urlRoot ).to.equal '/concepts'

  context 'defaults', ->

    it 'has an empty set for relations', ->
      expect( @model.get('properties') ).to.eql []
      expect( @model.get('terms') ).to.eql []

    it 'has empty sets for superconcept and subconcept ids', ->
      expect( @model.get('superconcept_ids') ).to.eql []
      expect( @model.get('subconcept_ids') ).to.eql []

  describe 'attributes', ->

    describe 'label', ->

      context 'when newly created', ->

        beforeEach ->
          sinon.stub I18n, 't'
          I18n.t.withArgs('concept.new_concept').returns '<new concept>'
          @model.isNew = -> true

        afterEach ->
          I18n.t.restore()

        it 'defaults to <new concept>', ->
          @model.set properties: [ key: 'label', value: 'gun' ]
          expect( @model.get('label') ).to.equal '<new concept>'

      context "after save", ->
        context "by term", ->
          it "uses first English term when no source language set", ->
            @model.set terms: [
                {
                  lang: "fr"
                  value: "poésie"
                }
                {
                  lang: "en"
                  value: "poetry"
                }
                {
                  lang: "en"
                  value: "poetics"
                }
              ]
            @model.initialize()
            expect( @model.get("label") ).to.equal "poetry"

          it "falls back to term in other language", ->
            @model.set terms: [
              lang: "fr"
              value: "poésie"
            ]
            @model.initialize()
            expect( @model.get("label") ).to.equal "poésie"

          it "handles term lang gracefully", ->
            @model.set terms: [
              {
                lang: "fr"
                value: "poésie"
              }
              {
                lang: "EN_US"
                value: "poetry"
              }
            ]
            @model.initialize()
            expect( @model.get("label") ).to.equal "poetry"

          context "with source language set", ->

            beforeEach ->
              Coreon.application =
                repositorySettings: ->
                  get: (arg) ->
                    return 'fr' if arg == 'sourceLanguage'
                  on: ->

            afterEach ->
              delete Coreon.application

            it "uses term in selected source language", ->
              @model.set terms: [
                {
                  lang: "fr"
                  value: "poésie"
                }
                {
                  lang: "en"
                  value: "poetry"
                }
              ]
              @model.initialize()
              expect( @model.get("label") ).to.equal "poésie"

            it "uses English term if not available in selected source language", ->
              @model.set terms: [
                {
                  lang: "de"
                  value: "Poesie"
                }
                {
                  lang: "en"
                  value: "poetry"
                }
              ]
              @model.initialize()
              expect( @model.get("label") ).to.equal "poetry"

          context "with source and target language set", ->

            beforeEach ->
              Coreon.application =
                repositorySettings: ->
                  get: (arg) ->
                    return 'fr' if arg == 'sourceLanguage'
                    return 'de' if arg == 'targetLanguage'
                  on: ->

            afterEach ->
              delete Coreon.application

            it "uses term in selected source language", ->
              @model.set terms: [
                {
                  lang: "fr"
                  value: "poésie"
                }
                {
                  lang: "en"
                  value: "poetry"
                }
              ]
              @model.initialize()
              expect( @model.get("label") ).to.equal "poésie"

            it "uses term in target language if not available in selected source language", ->
              @model.set terms: [
                {
                  lang: "de"
                  value: "Poesie"
                }
                {
                  lang: "en"
                  value: "poetry"
                }
              ]
              @model.initialize()
              expect( @model.get("label") ).to.equal "Poesie"

            it "uses English term if not available in selected source or target language", ->
              @model.set terms: [
                {
                  lang: "ru"
                  value: "поэзия"
                }
                {
                  lang: "en"
                  value: "poetry"
                }
              ]
              @model.initialize()
              expect( @model.get("label") ).to.equal "poetry"


        it "is overwritten by property", ->
          @model.set {
            properties: [
              key: "label"
              value: "My_label"
            ]
            terms: [
              lang: "en"
              value: "poetry"
            ]
          }
          @model.initialize()
          expect( @model.get("label") ).to.equal "My_label"

        context "with source language set to French", ->

          beforeEach ->
            Coreon.application =
              repositorySettings: () ->
                get: (arg)->
                  return 'fr' if arg == 'sourceLanguage'
                on: ->

          afterEach ->
            delete Coreon.application

          it "is overwritten by property in French", ->
            @model.set {
              properties: [
                {
                  key: "label"
                  value: "My_label"
                  lang: "en"
                }, {
                  key: "label"
                  value: "Mon_étiquette"
                  lang: "fr"
                }
              ]
              terms: [
                lang: "en"
                value: "poetry"
              ]
            }
            @model.initialize()
            expect( @model.get("label") ).to.equal "Mon_étiquette"

          it "is overwritten by first property if no French label property", ->
            @model.set {
              properties: [
                {
                  key: "label"
                  value: "My_label"
                }, {
                  key: "label"
                  value: "Mein_Label"
                  lang: "de"
                }
              ]
              terms: [
                lang: "en"
                value: "poetry"
              ]
            }
            @model.initialize()
            expect( @model.get("label") ).to.equal "My_label"

        context "with target language set to German", ->

          beforeEach ->
            Coreon.application =
              repositorySettings: () ->
                get: (arg)->
                  return 'de' if arg == 'targetLanguage'
                on: ->

          afterEach ->
            delete Coreon.application

          it "is overwritten by property in German", ->
            @model.set {
              properties: [
                {
                  key: "label"
                  value: "My_label"
                  lang: "en"
                }, {
                  key: "label"
                  value: "Mein_Label"
                  lang: "de"
                }
              ]
              terms: [
                lang: "en"
                value: "poetry"
              ]
            }
            @model.initialize()
            expect( @model.get("label") ).to.equal "Mein_Label"

          it "is overwritten by first property if no German label property", ->
            @model.set {
              properties: [
                {
                  key: "label"
                  value: "My_label"
                }, {
                  key: "label"
                  value: "Mon_étiquette"
                  lang: "fr"
                }
              ]
              terms: [
                lang: "en"
                value: "poetry"
              ]
            }
            @model.initialize()
            expect( @model.get("label") ).to.equal "My_label"



        context "with source language set to French and target language set to German", ->

          beforeEach ->
            Coreon.application =
              repositorySettings: () ->
                get: (arg)->
                  return 'fr' if arg == 'sourceLanguage'
                  return 'de' if arg == 'targetLanguage'
                on: ->

          afterEach ->
            delete Coreon.application

          it "is overwritten by property in German", ->
            @model.set {
              properties: [
                {
                  key: "label"
                  value: "My_label"
                  lang: "en"
                }, {
                  key: "label"
                  value: "Mein_Label"
                  lang: "de"
                }, {
                  key: "label"
                  value: "Mon_étiquette"
                  lang: "fr"
                }
              ]
              terms: [
                lang: "en"
                value: "poetry"
              ]
            }
            @model.initialize()
            expect( @model.get("label") ).to.equal "Mon_étiquette"



      context 'on changes', ->

        it 'updates label on id attribute changes', ->
          @model.set 'id', 'abc123'
          expect( @model.get('label') ).to.equal 'abc123'

        it 'updates label on property changes', ->
          @model.set 'properties', [
            key: 'label'
            value: 'My Label'
          ]
          expect( @model.get('label') ).to.equal 'My Label'

        it 'updates label on term changes', ->
          @model.set 'terms', [
            lang: 'en'
            value: 'poetry'
          ]
          expect( @model.get('label') ).to.equal 'poetry'


    describe 'hit', ->

      beforeEach ->
        @hits.add id: 'hit', result: @model
        @hit = @hits.at 0
        @hits.findByResult = (result) =>
          for hit in @hits.models
            return hit if hit.get('result') is result
          null
        @model.initialize()

      it 'gets hit from id', ->
        expect( @model.get('hit') ).to.equal @hit

      it 'updates hit on reset', ->
        @hits.reset []
        expect(@model.get 'hit').to.be.null

      it 'updates hit on remove', ->
        @hits.remove @hit
        expect(@model.get 'hit').to.be.null

      it 'updates hit when added', ->
        other = new Backbone.Model
        @hits.add result: other
        added = hit for hit in @hits.models when hit.get('result') is @model
        expect( @model.get('hit') ).to.equal added

  describe '.roots()', ->

    beforeEach ->
      Coreon.application =
        graphUri: -> 'https://api.coreon.com/123/'
      @collection = new Backbone.Collection
      sinon.stub Coreon.Models.Concept, 'collection', =>
        @collection
      sinon.stub Coreon.Modules.CoreAPI, 'sync', =>
        @request = $.Deferred()
        @request.promise()

    afterEach ->
      delete Coreon.application
      Coreon.Models.Concept.collection.restore()
      Coreon.Modules.CoreAPI.sync.restore()

    it 'fetches root concept ids thru API call', ->
      request = Coreon.Models.Concept.roots()
      sync = Coreon.Modules.CoreAPI.sync
      expect( sync ).to.have.been.calledOnce
      expect( sync ).to.have.been.calledWith "read", @collection
      options = sync.firstCall.args[2]
      expect( options ).to.have.property 'url',
        'https://api.coreon.com/123/concepts/roots'
      expect( options ).to.not.have.property 'batch'
      expect( request ).to.equal @request.promise()

  describe '#properties()', ->

    it 'syncs with attr', ->
      @model.set 'properties', [key: 'label']
      expect( @model.properties().at(0) ).to.be.an.instanceof Coreon.Models.Property
      expect( @model.properties().at(0).get('key') ).to.equal 'label'

  describe '#terms()', ->

    it 'creates terms from attr', ->
      @model.set 'terms', [value: 'dead', lang: 'en']
      expect( @model.terms().at(0) ).to.be.an.instanceof Coreon.Models.Term
      expect( @model.terms().at(0).get('value') ).to.equal 'dead'

    it 'updates attr from terms', ->
      @model.terms().reset [ value: 'dead', lang: 'en', properties: [] ]
      expect( @model.get('terms') ).to.eql [ value: 'dead', lang: 'en', properties: [], concept_id: "" ]

  describe '#info()', ->

    it 'returns hash with system info attributes', ->
      @model.set {
        id: 'abcd1234'
        admin: {author: 'Nobody'}
        terms : [ 'foo', 'bar' ]
        created_at: '2013-09-12 13:48'
        updated_at: '2013-09-12 13:50'
      }, silent: true
      expect( @model.info() ).to.eql
        id: 'abcd1234'
        author: 'Nobody'
        created_at: '2013-09-12 13:48'
        updated_at: '2013-09-12 13:50'

  describe '#propertiesByKey()', ->

    it 'returns empty hash when empty', ->
      @model.properties = -> models: []
      expect( @model.propertiesByKey() ).to.eql {}

    it 'returns properties grouped by key', ->
      prop1 = new Backbone.Model key: 'label'
      prop2 = new Backbone.Model key: 'definition'
      prop3 = new Backbone.Model key: 'definition'
      @model.properties = -> models: [ prop1, prop2, prop3 ]
      expect( @model.propertiesByKey() ).to.eql
        label: [ prop1 ]
        definition: [ prop2, prop3 ]

  describe '#termsByLang()', ->

    it 'returns empty hash when empty', ->
      @model.terms = -> new Backbone.Collection
      expect( @model.termsByLang() ).to.eql {}

    it 'returns terms grouped by lang', ->
      term1 = new Backbone.Model lang: 'en'
      term2 = new Backbone.Model lang: 'de'
      term3 = new Backbone.Model lang: 'de'
      @model.terms = -> new Backbone.Collection [ term1, term2, term3 ]
      expect( @model.termsByLang() ).to.eql
        en: [ term1 ]
        de: [ term2, term3 ]

  describe '#toJSON()', ->

    it 'returns wrapped attributes hash', ->
      @model.set
        id: 'my-concept'
        superconcept_ids: [ 'super_1', 'super_2' ]
        subconcept_ids: [ 'sub_1', 'sub_2' ]
      json = @model.toJSON()
      expect( json ).to.have.deep.property 'concept.id', 'my-concept'
      expect( json ).to.have.deep.property('concept.superconcept_ids').that.eql [ 'super_1', 'super_2' ]
      expect( json ).to.have.deep.property('concept.subconcept_ids').that.eql [ 'sub_1', 'sub_2' ]

    it 'drops client-side attributes', ->
      expect( @model.toJSON() ).to.not.have.deep.property 'concept.label'
      expect( @model.toJSON() ).to.not.have.deep.property 'concept.hit'

    it 'does not create wrapper for terms', ->
      @model.terms().reset [ { value: 'hat' }, { value: 'top hat' } ]
      expect( @model.toJSON() ).to.have.deep.property 'concept.terms[0].value', 'hat'
      expect( @model.toJSON() ).to.have.deep.property 'concept.terms[1].value', 'top hat'

  describe '#fetch()', ->

      beforeEach ->
        sinon.stub Coreon.Modules.CoreAPI, 'sync'

      afterEach ->
        Coreon.Modules.CoreAPI.sync.restore()

      it 'combines multiple subsequent calls into a single batch request', ->
        @model.fetch()
        expect( Coreon.Modules.CoreAPI.sync ).to.have.been.calledOnce
        expect( Coreon.Modules.CoreAPI.sync.firstCall.args[2] ).to.have.property 'batch', on

  describe '#save()', ->

    context 'application sync', ->

      beforeEach ->
        sinon.stub Coreon.Modules.CoreAPI, 'sync'

      afterEach ->
        Coreon.Modules.CoreAPI.sync.restore()

      it 'delegates to application sync', ->
        @model.save {}, wait: true
        expect( Coreon.Modules.CoreAPI.sync ).to.have.been.calledOnce
        expect( Coreon.Modules.CoreAPI.sync ).to.have.been.calledWith 'update', @model
        expect( Coreon.Modules.CoreAPI.sync.firstCall.args[2] ).to.have.property 'wait', true

    context 'create', ->

      beforeEach ->
        @model.id = null
        sinon.stub Coreon.Modules.CoreAPI, 'sync', (method, model, options = {}) ->
          model.id = '1234'
          options.success?()

      afterEach ->
        Coreon.Modules.CoreAPI.sync.restore()

      it 'triggers custom event', ->
        spy = sinon.spy()
        @model.on 'create', spy
        @model.save 'label', 'dead man'
        @model.save 'label', 'nobody'
        expect( spy ).to.have.been.calledOnce
        expect( spy ).to.have.been.calledWith @model, @model.id

  describe '#errors()', ->

    it 'collects remote validation errors', ->
      @model.trigger 'error', @model,
        responseText: '{"errors":{"foo":["must be bar"]}}'
      expect( @model.errors() ).to.eql
        foo: ['must be bar']

  describe '#revert()', ->

    it 'can restore last persisted state', ->
      @model.set 'label', 'high hat', silent: true
      @model.trigger 'sync'
      @model.set 'label', 'xxxx', silent: true
      @model.set 'label', '****', silent: true
      @model.revert()
      expect( @model.get('label') ).to.equal 'high hat'


  describe '#acceptsConnection()', ->
    beforeEach ->
      @model.id = 'c0ffee'
      @model.set 'subconcept_ids', ['bad1dea'], silent: true
      @model.set 'superconcept_ids', ['deadbeef'], silent: true

    it 'forbids simple circular connections', ->
      expect( @model.acceptsConnection('c0ffee') ).to.be.false
      expect( @model.acceptsConnection('bad1dea') ).to.be.false
      expect( @model.acceptsConnection('deadbeef') ).to.be.false

    it 'allows valid connections', ->
      expect( @model.acceptsConnection('f00baa') ).to.be.true

  describe '#path()', ->

    beforeEach ->
      Coreon.application =
        repositorySettings: ->

    afterEach ->
      delete Coreon.application

    it 'composes path from repository and id', ->
      Coreon.application = repository: ->
        path: -> '/hjkl9876'
      @model.id = '1234sdfg'
      expect( @model.path() ).to.equal '/hjkl9876/concepts/1234sdfg'

    it 'returns null path for new model', ->
      @model.isNew = -> true
      expect( @model.path() ).to.equal 'javascript:void(0)'

  describe '#broader()', ->

    sorted = null

    beforeEach ->
      sinon.stub Coreon.Models.Concept, 'find'
      sinon.stub Coreon.Modules.Collation, 'sortBy', ->
        sorted = @.slice()

    afterEach ->
      Coreon.Models.Concept.find.restore()
      Coreon.Modules.Collation.sortBy.restore()

    it 'returns a set containing the superconcepts', ->
      parent = new Backbone.Model
      @model.set 'superconcept_ids', [ 'p12345' ], silent: yes
      Coreon.Models.Concept.find.withArgs('p12345').returns parent
      expect( @model.broader() ).to.eql [ parent ]

  describe '#definition()', ->

    it 'returns null when no definition is given', ->
      @model.propertiesByKeyAndLang = -> {}
      expect( @model.definition() ).to.be.null

    it 'returns first definition in preferred lang', ->
      @model.propertiesByKeyAndLang = ->
       definition: [
        new Backbone.Model value: 'Eine Rose'
        new Backbone.Model value: "C'est ne pas un pipe"
       ]
      expect( @model.definition() ).to.equal 'Eine Rose'

  describe '#propertiesWithDefaults()', ->

    modelProperties = null
    propertiesFor = null
    formatter = null

    fakeBlueprintProperties = ->
      [key: 'label']

    fakeProperties = ->
      [new Backbone.Model]

    fakeFormattedProperties = ->
      [{}]

    beforeEach ->
      formatter = all: ->
      sinon.stub Coreon.Formatters, 'PropertiesFormatter', -> formatter
      propertiesFor = sinon.stub Coreon.Models.RepositorySettings, 'propertiesFor'
      propertiesFor.returns []
      @model.properties = -> []

    afterEach ->
      Coreon.Formatters.PropertiesFormatter.restore()
      Coreon.Models.RepositorySettings.propertiesFor.restore()

    it 'creates a formatter instance', ->
      blueprintProperties = fakeBlueprintProperties()
      propertiesFor.withArgs('concept').returns blueprintProperties
      modelProperties = fakeProperties()
      @model.properties = -> modelProperties
      @model.propertiesWithDefaults()
      constructor = Coreon.Formatters.PropertiesFormatter
      expect(constructor).to.have.been.calledOnce
      expect(constructor).to.have.been.calledWithNew
      expect(constructor).to.have.been.calledWith blueprintProperties, modelProperties

    it 'returns listing of all properties for display', ->
      formattedProperties = fakeFormattedProperties()
      formatter.all = ->
        formattedProperties
      result = @model.propertiesWithDefaults()
      expect(result).to.equal formattedProperties

  describe '#associativeRelations()', ->

    formatter = null
    edges_in = null
    edges_out = null
    relationTypes = null

    beforeEach ->
      formatter =
        associativeRelations: sinon.spy()
      sinon.stub Coreon.Formatters, 'RelationsFormatter', -> formatter
      relationTypes = sinon.stub
      Coreon.Models.RepositorySettings.relationTypes = -> relationTypes
      edges_in = sinon.stub
      edges_out = sinon.stub
      @model.set 'edges_in', edges_in
      @model.set 'edges_out', edges_out

    afterEach ->
      Coreon.Formatters.RelationsFormatter.restore()

    it 'creates a relations formatter instance', ->
      @model.associativeRelations()
      constructor = Coreon.Formatters.RelationsFormatter
      expect(constructor).to.have.been.calledOnce
      expect(constructor).to.have.been.calledWithNew
      expect(constructor).to.have.been.calledWith relationTypes, edges_in, edges_out

    it 'gathers the associative relations from the formatter', ->
      @model.associativeRelations()
      expect(formatter.associativeRelations).to.have.been.calledOnce




