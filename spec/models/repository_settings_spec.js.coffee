#= require spec_helper
#= require models/repository_settings
#= require modules/core_api

describe 'Coreon.Models.RepositorySettings', ->

  fetch_spy = sinon.spy Coreon.Models.RepositorySettings.prototype, 'fetch'

  beforeEach ->
    Coreon.application =
      repository: ->
        get: (arg) ->
          '111' if arg == 'id'
      graphUri: ->
        'some_uri'

  afterEach ->
    fetch_spy.reset()
    delete Coreon.application
    Coreon.Models.RepositorySettings.resetCurrent()

  describe ".current", ->

    it "creates a singleton instance of the repository settings", ->
      settings = Coreon.Models.RepositorySettings.current()
      othersettings = Coreon.Models.RepositorySettings.current()

      expect(settings).to.be.instanceof(Coreon.Models.RepositorySettings)
      expect(othersettings).to.be.equal(settings)

    it 'creates a new singleton instance when forced even if it exists', ->
      settings = Coreon.Models.RepositorySettings.current()
      othersettings = Coreon.Models.RepositorySettings.current(true)

      expect(othersettings).to.not.be.equal(settings)

  describe "#blueprints_for", ->

    xit "returns an array of blueprints for a given type, when model is synched", ->

    xit "returns an array of blueprints for a given type, when model is NOT synched", ->

  describe "#properties_for", ->

    xit "returns an array of blueprints for a given type, when model is synched", ->

    xit "returns an array of blueprints for a given type, when model is NOT synched", ->


  # describe "#settings", ->

  #   beforeEach ->
  #     Coreon.application =
  #       repository: ->
  #         get: (arg) ->
  #           '111' if arg == 'id'
  #       graphUri: ->
  #         'some_uri'

  #   afterEach ->
  #     delete Coreon.application
  #     Coreon.Modules.CoreAPI.ajax.restore()

  #   it 'requests settings from API', ->
  #     model.

  #     ajax = Coreon.Modules.CoreAPI.ajax
  #     expect(ajax).to.have.been.calledOnce
  #     expect(ajax).to.have.been.calledWith "some_uri/repository/settings", {type: 'GET', dataType: 'json'}

  #   xit 'sets the remote settings when fetched', ->
  #     model.settings()
  #     success some: 'data'

  #     # expect(model._settings).to.not.be.equal some: 'data'
  #     # expect(model._id).to.be.equal '111'

  #   xit 'should not make an ajax call if the settings are already fetched', ->
  #     model.getSettings()
  #     model.getSettings()

  #     expect(Coreon.Modules.CoreAPI.ajax).to.have.been.calledOnce
  #     expect(model._settings).to.not.beNull
  #     expect(model._id).to.be.equal '111'