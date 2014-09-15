#= require spec_helper
#= require models/repository_settings
#= require modules/core_api

describe 'Coreon.Models.RepositorySettings', ->

  fetchStub = null
  sample_blueprints = [
                        {
                          for: 'concept',
                          properties: [
                            {key: 'label', type: 'boolean'}
                          ]
                        }
                      ]

  beforeEach ->
    Coreon.application =
      repository: ->
        get: (arg) ->
          '111' if arg == 'id'
      graphUri: ->
        'some_uri'

  afterEach ->
    delete Coreon.application

  context "model class", ->

    settings = null

    beforeEach ->
      fetchStub = sinon.stub(Coreon.Models.RepositorySettings.prototype, 'fetch').yieldsTo('success', some: 'data');
      Coreon.Models.RepositorySettings.refresh().done (response) ->
        settings = response

    afterEach ->
      fetchStub.restore()
      Coreon.Models.RepositorySettings.reset()

    describe ".refresh", ->

      it 'creates a singleton instance of the repository settings', ->
        othersettings = null
        Coreon.Models.RepositorySettings.refresh().done (response) ->
          othersettings = response

        expect(settings).to.be.instanceof(Coreon.Models.RepositorySettings)
        expect(settings).to.be.equal(othersettings)

      it 'creates a new singleton instance when forced even if it exists', ->
        othersettings = null
        Coreon.Models.RepositorySettings.refresh(true).done (response) ->
          othersettings = response

        expect(othersettings).to.not.be.equal(settings)

      describe '.blueprintsFor', ->

        it 'delegates to the singleton\'s instance #blueprintsFor', ->
          blueprintsFor_spy = sinon.spy(Coreon.Models.RepositorySettings.prototype, 'blueprintsFor')
          Coreon.Models.RepositorySettings.blueprintsFor('concept')

          expect(blueprintsFor_spy).to.have.been.calledOnce

        it 'delegates to the singleton\'s instance #propertiesFor', ->
          propertiesFor_spy = sinon.spy(Coreon.Models.RepositorySettings.prototype, 'propertiesFor')
          Coreon.Models.RepositorySettings.propertiesFor('concept')

          expect(propertiesFor_spy).to.have.been.calledOnce

        it 'delegates to the singleton\'s instance #propertyFor', ->
          propertyFor_spy = sinon.spy(Coreon.Models.RepositorySettings.prototype, 'propertyFor')
          Coreon.Models.RepositorySettings.propertyFor('concept', 'lala')

          expect(propertyFor_spy).to.have.been.calledOnce


  context 'model instance', ->

    model = null

    beforeEach ->
      model = new Coreon.Models.RepositorySettings()
      model.set 'blueprints', sample_blueprints

    describe '#blueprintsFor', ->

      it 'returns an array of blueprints for a given entity', ->
        expect(model.blueprintsFor('concept')).to.be.eql {
            for: 'concept',
            properties: [
              {key: 'label', type: 'boolean'}
            ]
          }

    describe '#propertiesFor', ->

      it 'returns an array of properties for a given entity', ->
        expect(model.propertiesFor('concept')).to.be.eql [
            {key: 'label', type: 'boolean'}
          ]

    describe '#propertyFor', ->

      it 'returns a property for a given entity and type', ->
        expect(model.propertyFor('concept', 'label')).to.be.eql key: 'label', type: 'boolean'