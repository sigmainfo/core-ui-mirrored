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

  context "validation errors", ->

    it "renders error summary", ->
      I18n.t.withArgs("form.errors.summary.create", name: "model").returns "Failed to create model:"
      @model.isNew = -> true
      @model.errors = -> {}
      markup = @helper "model", @model, ->
      form = $(markup)
      form.should.have ".errors"
      form.find(".errors *:first-child").should.have.text "Failed to create model:"

    it "renders error count for attrs", ->
      I18n.t.withArgs("form.errors.attribute", name: "properties", count: 3).returns "3 errors on properties"
      @model.errors = -> 
        properties: ["are invalid"],
        nested_errors_on_properties: [
          { value: ["can't be foo", "can't be bar"] }
          { key:   ["can't be baz"] }
        ]
      markup = @helper "model", @model, ->
      form = $(markup)
      form.find(".errors li").should.contain "3 errors on properties"
