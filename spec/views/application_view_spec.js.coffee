#= require spec_helper
#= require views/application_view

describe "Coreon.Views.ApplicationView", ->

  beforeEach ->
    sinon.stub Coreon.Views.Layout, "HeaderView", -> new Backbone.View

    session = new Backbone.Model
      notifications: new Backbone.Collection

    @view = new Coreon.Views.ApplicationView
      model:
        session: session

  afterEach ->
    Coreon.Views.Layout.HeaderView.restore()
    

  xdescribe "render()", ->

    it "renders template", ->
      sinon.stub Coreon.Templates, "application"

       
