#= require spec_helper
#= require environment

describe "config/environment", ->

  context "require", ->
    
    it "loads core dependencies", ->
      lib for lib in [jQuery, _, Backbone, HAML]

    it "prepares translations", ->
      should.exist I18n
      should.exist I18n.translations
      I18n.translations.en.date.day_names[0].should.equal "Sunday"

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

  it "makes helpers available to template context", ->
    HAML.globals().should.equal Coreon.Helpers

  it "configures models for use with Mongoid id field", ->
    model = new Backbone.Model _id: "1234"
    model.id.should.equal "1234"

  it "sets Views prototpye for destroy() to call remove()", ->
    Backbone.View::remove = sinon.spy()
    Backbone.View::destroy()
    Backbone.View::remove.should.have.been.calledOnce

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
      
       
