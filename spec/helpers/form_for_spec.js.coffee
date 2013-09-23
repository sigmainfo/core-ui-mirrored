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

  it "maks form for disable on submit", ->
    markup = @helper "my_model", @model, ->
    $(markup).should.have.attr "data-xhr-form", "disable"

  it "turns off client side browser validations", ->
    markup = @helper "my_model", @model, ->
    $(markup).should.have.attr "novalidate"

  it "classifies form", ->
    markup = @helper "my_model", @model, ->
    $(markup).should.have.class "my-model"

  it "renders cancel link", ->
    I18n.t.withArgs("form.cancel").returns "Cancel"
    markup = @helper "model", @model, ->
    form = $(markup)
    form.should.have "a.cancel"
    form.find("a.cancel").should.have.attr "href", "javascript:void(0)"
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

    it "does not render reset link", ->
      @model.isNew = -> true
      markup = @helper "model", @model, ->
      form = $(markup)
      form.should.not.have "a.reset"

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

    it "renders reset link", ->
      I18n.t.withArgs("form.reset").returns "Reset"
      markup = @helper "model", @model, ->
      form = $(markup)
      form.should.have "a.reset"
      form.find("a.reset").should.have.attr "href", "javascript:void(0)"
      form.find("a.reset").should.have.text "Reset"

  context "validation errors", ->

    it "renders error summary", ->
      I18n.t.withArgs("form.errors.summary.create", name: "model").returns "Failed to create model:"
      @model.isNew = -> true
      @model.errors = -> {}
      markup = @helper "model", @model, ->
      form = $(markup)
      form.should.have ".error-summary"
      form.find(".error-summary *:first-child").should.have.text "Failed to create model:"

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
      form.find(".error-summary li").should.contain "3 errors on properties"

  describe "input()", ->

    beforeEach ->
      sinon.stub Coreon.Helpers, "input"

    afterEach ->
      Coreon.Helpers.input.restore()
    
    it "delegates call to input helper", ->
      @helper "model", @model, -> @form.input "label", required: true
      Coreon.Helpers.input.should.have.been.calledOnce
      Coreon.Helpers.input.should.have.been.calledWith "model", "label", @model, required: true
