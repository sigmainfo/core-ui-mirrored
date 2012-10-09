#= require spec_helper
#= require environment

describe "config/environment", ->

  it "loads core dependencies", ->
    lib.should.exist for lib in [jQuery, _, Backbone, HAML]

  it "prepares translations", ->
    I18n.should.exist
    I18n.translations.should.exist
    I18n.translations.en.date.day_names[0].should.equal "Sunday"

  it "prepares namespaces", ->
    Coreon.should.exist

    Coreon.Models.should.exist
    Coreon.Collections.should.exist
    Coreon.Modules.should.exist
    Coreon.Helpers.should.exist
    Coreon.Routers.should.exist

    Coreon.Views.should.exist
    Coreon.Views.Layout.should.exist
    Coreon.Views.Widgets.should.exist
    Coreon.Views.Account.should.exist
    Coreon.Views.Search.should.exist
    Coreon.Views.Concepts.should.exist
    Coreon.Views.Properties.should.exist

  it "makes helpers available to template context", ->
    HAML.globals().should.equal Coreon.Helpers

  it "configures models for use with Mongoid id field", ->
    model = new Backbone.Model _id: "1234"
    model.id.should.equal "1234"
