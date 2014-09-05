#= require spec_helper
#= require models/repository_settings
#= require modules/core_api

describe 'Coreon.Models.RepositorySettings', ->

  fetchStub = null

  beforeEach ->
    Coreon.application =
      repository: ->
        get: (arg) ->
          '111' if arg == 'id'
      graphUri: ->
        'some_uri'
    fetchStub = sinon.stub(Coreon.Models.RepositorySettings.prototype, 'fetch').yieldsTo('success', some: 'data');

  afterEach ->
    fetchStub.restore()
    delete Coreon.application
    Coreon.Models.RepositorySettings.reset()

  context "model class", ->

    describe ".refresh", ->

      it "creates a singleton instance of the repository settings", ->
        settings = null
        Coreon.Models.RepositorySettings.refresh().done (response) ->
          settings = response
        othersettings = null
        Coreon.Models.RepositorySettings.refresh().done (response) ->
          othersettings = response

        expect(settings).to.be.instanceof(Coreon.Models.RepositorySettings)
        expect(settings).to.be.equal(othersettings)

      it 'creates a new singleton instance when forced even if it exists', ->
        settings = null
        Coreon.Models.RepositorySettings.refresh().done (response) ->
          settings = response
        othersettings = null
        Coreon.Models.RepositorySettings.refresh(true).done (response) ->
          othersettings = response

        expect(othersettings).to.not.be.equal(settings)

  context 'model instance', ->

    model = null

    beforeEach ->
      model = new Coreon.Models.RepositorySettings()
      model.set 'blueprints', [
        {
          for: 'concept',
          properties: [
            {key: 'label', type: 'boolean'}
          ]
        }
      ]

    describe "#blueprintsFor", ->

      it "returns an array of blueprints for a given type", ->
        expect(model.blueprintsFor('concept')).to.be.eql {
            for: 'concept',
            properties: [
              {key: 'label', type: 'boolean'}
            ]
          }

    describe "#propertiesFor", ->

      it "returns an array of properties for a given type", ->
        expect(model.propertiesFor('concept')).to.be.eql [
            {key: 'label', type: 'boolean'}
          ]