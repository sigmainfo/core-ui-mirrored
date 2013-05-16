#= require spec_helper
#= require modules/core_api

describe "Coreon.Modules.GraphSync", ->

  beforeEach ->
    @_application = Coreon.application
    Coreon.application =
      session: null

  afterEach ->
    Coreon.application = @_application

  describe "sync()", ->

    before ->
      @sync = Coreon.Modules.CoreAPI.sync

    beforeEach ->
      sinon.stub Backbone, "sync"
      @model = new Backbone.Model

    afterEach ->
      Backbone.sync.restore()
  
    context "with valid session", ->
      
      it "delegates to Backbone.sync", ->
        @sync "create", @model, data: browser: "Google Chrome"
        Backbone.sync.should.have.been.calledWith "create", @model
