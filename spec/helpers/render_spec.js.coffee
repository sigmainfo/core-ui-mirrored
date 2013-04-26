#= require spec_helper
#= require helpers/render

describe "Coreon.Helpers.render()", ->

  beforeEach ->
    @helper = Coreon.Helpers.render
    Coreon.Templates ?= {}

  it "renders provided template", ->
    Coreon.Templates["konacha/render"] = (context) ->
      "<h3>#{context.title}</h3>"
    try
      markup = @helper "konacha/render", title: "Wahappan?" 
      markup.should.equal "<h3>Wahappan?</h3>"
    finally
      delete Coreon.Templates["konacha/render"]
    
