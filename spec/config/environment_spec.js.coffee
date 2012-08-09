#= require spec_helper
#= require environment

describe "config/environment", ->

  it "loads core dependencies", ->
    lib.should.exist for lib in [jQuery, _, Backbone, HAML]

  it "prepares translations", ->
    I18n.should.exist
    I18n.translations.should.exist
    I18n.translations.en.date.day_names[0].should.equal "Sunday"

  it "loads core-client lib", ->
    CoreClient.should.exist 

  it "prepares namespaces", ->
    Coreon.should.exist

    Coreon.Models.should.exist
    Coreon.Collections.should.exist
    Coreon.Helpers.should.exist
    Coreon.Routers.should.exist

    Coreon.Views.should.exist
    Coreon.Views.Layout.should.exist


  it "makes helpers available to template context", ->
    HAML.globals().should.equal Coreon.Helpers


