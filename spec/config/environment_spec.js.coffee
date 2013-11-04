#= require spec_helper
#= require environment

describe "config/environment", ->

  context "require", ->

    it "loads core dependencies", ->
      should.exist lib for lib in [jQuery, _, Backbone, HAML]

    it "prepares translations", ->
      should.exist I18n
      should.exist I18n.translations
      I18n.translations.en.date.day_names[0].should.equal "Sunday"

    it "makes helpers available to template context", ->
      HAML.globals().should.equal Coreon.Helpers

  context "namespaces", ->

    it "opens up namespace", ->
      should.exist Coreon

    it "creates first level namespaces", ->
      should.exist Coreon.Models
      should.exist Coreon.Collections
      should.exist Coreon.Modules
      should.exist Coreon.Helpers
      should.exist Coreon.Routers
      should.exist Coreon.Lib

    it "prepares view namespaces", ->
      should.exist Coreon.Views
      should.exist Coreon.Views.Layout
      should.exist Coreon.Views.Widgets
      should.exist Coreon.Views.Account
      should.exist Coreon.Views.Sessions
      should.exist Coreon.Views.Search
      should.exist Coreon.Views.Repositories
      should.exist Coreon.Views.Concepts
      should.exist Coreon.Views.Concepts.Shared
      should.exist Coreon.Views.Properties
      should.exist Coreon.Views.Terms

  describe "Backbone.View::destroy()", ->

    it "calls remove", ->
      @view = new Backbone.View
      @view.remove = sinon.spy()
      @view.destroy()
      @view.remove.should.have.been.calledOnce
      @view.remove.should.have.been.calledOn @view

  context "error notifications", ->

    beforeEach ->
      sinon.stub Backbone.$, "ajax", => $.Deferred()

    afterEach ->
      Backbone.$.ajax.restore()

    it "delegates to $", ->
      Backbone.ajax "https://auth.coreon.com/login"
      Backbone.$.ajax.should.have.been.calledOnce
      Backbone.$.ajax.should.have.been.calledWith "https://auth.coreon.com/login"

    it "uses error notifications when possible", ->
      Coreon.Modules.ErrorNotifications = failHandler: sinon.spy()
      request = Backbone.ajax()
      request.reject error: "Stupid fucking white man."
      Coreon.Modules.ErrorNotifications.failHandler.should.have.been.calledOnce
      Coreon.Modules.ErrorNotifications.failHandler.should.have.been.calledWith error: "Stupid fucking white man."

    it "fails gracefully when no error notifications handler is loaded", ->
      Coreon.Modules.ErrorNotifications = null
      (-> Backbone.ajax() ).should.not.throw Error
