#= require spec_helper
#= require helpers/form_for

describe "Coreon.Helpers.form_for()", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @model = new Backbone.Model
    @helper = Coreon.Helpers.form_for

  afterEach ->
    I18n.t.restore()

  it "wraps block with form tag", ->
    markup = @helper "model", @model, -> '<input type="text" name="title" value="Wahappan?"/>'
    form = $(markup)
    form.should.match "form"
    form.should.have 'input[type="text"][name="title"][value="Wahappan?"]'

  it "classifies form", ->
    markup = @helper "my_model", @model, ->
    $(markup).should.have.class "my-model"

  it "renders cancel link", ->
    I18n.t.withArgs("form.cancel").returns "Cancel"
    markup = @helper "model", @model, ->
    form = $(markup)
    form.should.have "a.cancel"
    form.find("a.cancel").should.have.attr "href", "javascript:history.back()"
    form.find("a.cancel").should.have.text "Cancel"

  context "new model", ->
    
    beforeEach ->
      @model.isNew = -> true

    it "classifies form", ->
      markup = @helper "model", @model, ->
      $(markup).should.have.class "create"

    it "renders submit button", ->
      I18n.t.withArgs("model.create").returns "Create Model"
      markup = @helper "model", @model, ->
      form = $(markup)
      form.should.have 'button[type="submit"]'
      form.find('button[type="submit"]').should.have.text "Create Model"

  context "existing model", ->

    beforeEach ->
      @model.isNew = -> false

    it "classifies form", ->
      markup = @helper "model", @model, ->
      $(markup).should.have.class "update"

    it "renders submit button", ->
      I18n.t.withArgs("model.update").returns "Update Model"
      markup = @helper "model", @model, ->
      form = $(markup)
      form.should.have 'button[type="submit"]'
      form.find('button[type="submit"]').should.have.text "Update Model"

  describe "fields_for", ->
  
    it "delegates to field for helper", ->
      sinon.stub Coreon.Helpers, "fields_for"
      try
        block = ->
        @helper "my_model", @model, ->
          @form.fields_for "properties", block
        Coreon.Helpers.fields_for.should.have.been.calledWith "properties", @model, block
      finally
        Coreon.Helpers.fields_for.restore()
      
    
