#= require spec_helper
#= require models/concept

describe 'Coreon.Models.Concept', ->

  beforeEach ->
    @hits = new Backbone.Collection
    @hits.findByResult = -> null
    sinon.stub Coreon.Collections.Hits, 'collection', => @hits
    @model = new Coreon.Models.Concept id: '123'

  afterEach ->
    Coreon.Collections.Hits.collection.restore()

  it 'is a Backbone model', ->
    @model.should.been.an.instanceof Backbone.Model

  it 'is an accumulating model', ->
    Coreon.Models.Concept.find.should.equal Coreon.Modules.Accumulation.find

  it 'uses Concepts collection for accumulation', ->
    collection = Coreon.Models.Concept.collection()
    collection.should.be.an.instanceof Coreon.Collections.Concepts
    Coreon.Models.Concept.collection().should.equal collection

  it 'has an URL root', ->
    @model.urlRoot.should.equal '/concepts'

  context 'defaults', ->

    it 'has an empty set for relations', ->
      @model.get('properties').should.eql []
      @model.get('terms').should.eql []

    it 'has empty sets for superconcept and subconcept ids', ->
      @model.get('superconcept_ids').should.eql []
      @model.get('subconcept_ids').should.eql []

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
          @model.get('label').should.equal '<new concept>'

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
            @model.get("label").should.equal "poetry"

          it "falls back to term in other language", ->
            @model.set terms: [
              lang: "fr"
              value: "poésie"
            ]
            @model.initialize()
            @model.get("label").should.equal "poésie"
          
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
            @model.get("label").should.equal "poetry"  
            
          context "with source language set", ->  
          
            beforeEach ->
              Coreon.application = 
                repositorySettings: (arg) -> 
                  return 'fr' if arg == 'sourceLanguage'
                  
            afterEach ->
              delete Coreon.application
          
            it "uses term in selected source language", ->
              #console.log Coreon.application.repositorySettings
              
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
              @model.get("label").should.equal "poésie"

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
              @model.get("label").should.equal "poetry"
            
          context "with source and target language set", ->
            
            beforeEach ->
              Coreon.application = 
                repositorySettings: (arg) -> 
                  return 'fr' if arg == 'sourceLanguage'
                  return 'de' if arg == 'targetLanguage'
                
            afterEach ->
              delete Coreon.application
        
            it "uses term in selected source language", ->
              #console.log Coreon.application.repositorySettings
            
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
              @model.get("label").should.equal "poésie"

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
              @model.get("label").should.equal "Poesie"
          
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
              @model.get("label").should.equal "poetry"
              

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
          }, silent: true
          @model.initialize()
          @model.get("label").should.equal "My_label"


      context 'on changes', ->

        it 'updates label on id attribute changes', ->
          @model.set 'id', 'abc123'
          @model.get('label').should.equal 'abc123'

        it 'updates label on property changes', ->
          @model.set 'properties', [
            key: 'label'
            value: 'My Label'
          ]
          @model.get('label').should.equal 'My Label'

        it 'updates label on term changes', ->
          @model.set 'terms', [
            lang: 'en'
            value: 'poetry'
          ]
          @model.get('label').should.equal 'poetry'


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
        @model.get('hit').should.equal @hit

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
        @model.get('hit').should.equal added

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
      @model.properties().at(0).should.be.an.instanceof Coreon.Models.Property
      @model.properties().at(0).get('key').should.equal 'label'

  describe '#terms()', ->

    it 'creates terms from attr', ->
      @model.set 'terms', [value: 'dead', lang: 'en']
      @model.terms().at(0).should.be.an.instanceof Coreon.Models.Term
      @model.terms().at(0).get('value').should.equal 'dead'

    it 'updates attr from terms', ->
      @model.terms().reset [ value: 'dead', lang: 'en', properties: [] ]
      @model.get('terms').should.eql [ value: 'dead', lang: 'en', properties: [] ]

  describe '#info()', ->

    it 'returns hash with system info attributes', ->
      @model.set {
        id: 'abcd1234'
        admin: {author: 'Nobody'}
        terms : [ 'foo', 'bar' ]
        created_at: '2013-09-12 13:48'
        updated_at: '2013-09-12 13:50'
      }, silent: true
      @model.info().should.eql
        id: 'abcd1234'
        author: 'Nobody'
        created_at: '2013-09-12 13:48'
        updated_at: '2013-09-12 13:50'

  describe '#propertiesByKey()', ->

    it 'returns empty hash when empty', ->
      @model.properties = -> models: []
      @model.propertiesByKey().should.eql {}

    it 'returns properties grouped by key', ->
      prop1 = new Backbone.Model key: 'label'
      prop2 = new Backbone.Model key: 'definition'
      prop3 = new Backbone.Model key: 'definition'
      @model.properties = -> models: [ prop1, prop2, prop3 ]
      @model.propertiesByKey().should.eql
        label: [ prop1 ]
        definition: [ prop2, prop3 ]

  describe '#termsByLang()', ->

    it 'returns empty hash when empty', ->
      @model.terms = -> models: []
      @model.termsByLang().should.eql {}

    it 'returns terms grouped by lang', ->
      term1 = new Backbone.Model lang: 'en'
      term2 = new Backbone.Model lang: 'de'
      term3 = new Backbone.Model lang: 'de'
      @model.terms = -> models: [ term1, term2, term3 ]
      @model.termsByLang().should.eql
        en: [ term1 ]
        de: [ term2, term3 ]
        
    context 'with source language set to de', ->
      
      beforeEach ->
        Coreon.application = 
          repositorySettings: ->
            get: (arg) ->
              return 'de' if arg == 'sourceLanguage'
      
      afterEach ->
        delete Coreon.application
        
      it 'gives source language´s terms first', ->
      
        term1 = new Backbone.Model lang: 'en'
        term2 = new Backbone.Model lang: 'de'
        term3 = new Backbone.Model lang: 'fr'
        term4 = new Backbone.Model lang: 'de'
        @model.terms = -> models: [ term1, term2, term3, term4 ]
        
        @model.termsByLang().should.eql
          de: [ term2, term4 ]
          en: [ term1 ]
          fr: [ term3 ]

    context 'with target language set to fr', ->
      
      beforeEach ->
        Coreon.application = 
          repositorySettings: ->
            get: (arg) ->
              return 'fr' if arg == 'targetLanguage'
      
      afterEach ->
        delete Coreon.application
        
      it 'gives source language´s terms first', ->
      
        term1 = new Backbone.Model lang: 'en'
        term2 = new Backbone.Model lang: 'de'
        term3 = new Backbone.Model lang: 'fr'
        term4 = new Backbone.Model lang: 'de'
        @model.terms = -> models: [ term1, term2, term3, term4 ]
        
        @model.termsByLang().should.eql
          fr: [ term3 ]
          en: [ term1 ]
          de: [ term2, term4 ]

    context 'with source language set to de and target language set to fr', ->
      
      beforeEach ->
        Coreon.application = 
          repositorySettings: ->
            get: (arg) ->
              return 'de' if arg == 'sourceLanguage'
              return 'fr' if arg == 'targetLanguage'
      
      afterEach ->
        delete Coreon.application
        
      it 'gives source language´s terms first', ->
      
        term1 = new Backbone.Model lang: 'en'
        term2 = new Backbone.Model lang: 'de'
        term3 = new Backbone.Model lang: 'fr'
        term4 = new Backbone.Model lang: 'de'
        @model.terms = -> models: [ term1, term2, term3, term4 ]
        
        @model.termsByLang().should.eql
          de: [ term2, term4 ]
          fr: [ term3 ]
          en: [ term1 ]
          
      it 'gives empty array for languages that are requested, but not found', ->
        term1 = new Backbone.Model lang: 'en'
        term2 = new Backbone.Model lang: 'de'
        term3 = new Backbone.Model lang: 'de'
        @model.terms = -> models: [ term1, term2, term3 ]
        
        @model.termsByLang().should.eql
          de: [ term2, term3 ]
          fr: [ ]
          en: [ term1 ]
        

  describe '#toJSON()', ->

    it 'returns wrapped attributes hash', ->
      @model.set
        id: 'my-concept'
        superconcept_ids: [ 'super_1', 'super_2' ]
        subconcept_ids: [ 'sub_1', 'sub_2' ]
      json = @model.toJSON()
      json.should.have.deep.property 'concept.id', 'my-concept'
      json.should.have.deep.property('concept.superconcept_ids').that.eql [ 'super_1', 'super_2' ]
      json.should.have.deep.property('concept.subconcept_ids').that.eql [ 'sub_1', 'sub_2' ]

    it 'drops client-side attributes', ->
      @model.toJSON().should.not.have.deep.property 'concept.label'
      @model.toJSON().should.not.have.deep.property 'concept.hit'

    it 'does not create wrapper for terms', ->
      @model.terms().reset [ { value: 'hat' }, { value: 'top hat' } ]
      @model.toJSON().should.have.deep.property 'concept.terms[0].value', 'hat'
      @model.toJSON().should.have.deep.property 'concept.terms[1].value', 'top hat'

  describe '#fetch()', ->

      beforeEach ->
        sinon.stub Coreon.Modules.CoreAPI, 'sync'

      afterEach ->
        Coreon.Modules.CoreAPI.sync.restore()

      it 'combines multiple subsequent calls into a single batch request', ->
        @model.fetch()
        Coreon.Modules.CoreAPI.sync.should.have.been.calledOnce
        Coreon.Modules.CoreAPI.sync.firstCall.args[2].should.have.property 'batch', on

  describe '#save()', ->

    context 'application sync', ->

      beforeEach ->
        sinon.stub Coreon.Modules.CoreAPI, 'sync'

      afterEach ->
        Coreon.Modules.CoreAPI.sync.restore()

      it 'delegates to application sync', ->
        @model.save {}, wait: true
        Coreon.Modules.CoreAPI.sync.should.have.been.calledOnce
        Coreon.Modules.CoreAPI.sync.should.have.been.calledWith 'update', @model
        Coreon.Modules.CoreAPI.sync.firstCall.args[2].should.have.property 'wait', true

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
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith @model, @model.id

  describe '#errors()', ->

    it 'collects remote validation errors', ->
      @model.trigger 'error', @model,
        responseText: '{"errors":{"foo":["must be bar"]}}'
      @model.errors().should.eql
        foo: ['must be bar']

  describe '#revert()', ->

    it 'can restore last persisted state', ->
      @model.set 'label', 'high hat', silent: true
      @model.trigger 'sync'
      @model.set 'label', 'xxxx', silent: true
      @model.set 'label', '****', silent: true
      @model.revert()
      @model.get('label').should.equal 'high hat'


  describe '#acceptsConnection()', ->
    beforeEach ->
      @model.id = 'c0ffee'
      @model.set 'subconcept_ids', ['bad1dea'], silent: true
      @model.set 'superconcept_ids', ['deadbeef'], silent: true

    it 'forbids simple circular connections', ->
      @model.acceptsConnection('c0ffee').should.be.false
      @model.acceptsConnection('bad1dea').should.be.false
      @model.acceptsConnection('deadbeef').should.be.false

    it 'allows valid connections', ->
      @model.acceptsConnection('f00baa').should.be.true

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

