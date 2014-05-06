#= require spec_helper
#= require helpers/input

describe "Coreon.Helpers.input()", ->

  beforeEach ->
    @stub I18n, "t"
    @model = new Backbone.Model
    @helper = Coreon.Helpers.input

  it "creates container", ->
    markup = @helper "model", "attrName"
    input = $(markup)
    input.should.match ".input.attr-name"

  it "marks required inputs", ->
    markup = @helper "model", "attrName", null, required: true
    input = $(markup)
    input.should.have.class "required"
    tag = input.find "input"
    tag.should.have.attr "required", "required"

  context "input tag", ->

    it "renders input tag", ->
      @model.set "attrName", "foo bar baz", silent: true
      markup = @helper "model", "attrName", @model
      input = $(markup)
      input.should.have 'input'
      tag = input.find "input"
      tag.should.have.attr "type", "text"
      tag.should.have.attr "name", "model[attrName]"
      tag.should.have.attr "id", "model-attr-name"
      tag.should.have.attr "value", "foo bar baz"

    it "renders empty value without a model", ->
      markup = @helper "model", "attrName"
      input = $(markup)
      tag = input.find "input"
      tag.should.have.attr "value", ""

    it "renders empty value when undefined", ->
      @model.unset "attrName", silent: true
      markup = @helper "model", "attrName", @model
      input = $(markup)
      tag = input.find "input"
      tag.should.have.attr "value", ""

    it "uses type from options", ->
      markup = @helper "model", "attrName", null, type: "email"
      input = $(markup)
      tag = input.find "input"
      tag.should.have.attr "type", "email"

    it "uses scope from options", ->
      markup = @helper "property", "key", null, scope: "concept[properties][]"
      input = $(markup)
      tag = input.find "input"
      tag.should.have.attr "name", "concept[properties][][key]"
      tag.attr("id").should.match /^concept-properties-\d+-key$/

    it "interpolates index into scope", ->
      markup = @helper "property", "key", null, scope: "concept[properties][]", index: 3
      input = $(markup)
      tag = input.find "input"
      tag.should.have.attr "name", "concept[properties][3][key]"
      tag.should.have.attr "id", "concept-properties-3-key"

  context "textarea tag", ->

    it "renders textarea", ->
      @model.set "attrName", "foo bar baz", silent: true
      markup = @helper "model", "attrName", @model, type: "textarea"
      input = $(markup)
      input.should.have "textarea"
      tag = input.find "textarea"
      tag.should.have.attr "name", "model[attrName]"
      tag.should.have.attr "id", "model-attr-name"
      tag.should.have.text "foo bar baz"

  context "hidden tag", ->
    beforeEach ->
      @model.set "attrName", "foo bar baz", silent: true
      @input = $(@helper "model", "attrName", @model, type: "hidden")

    it "skips container and label", ->
      @input.should.not.match ".input.attr-name"
      @input.should.match "input"

    it "renders hidden field", ->
      @input.should.have.attr "name", "model[attrName]"
      @input.should.have.attr "id", "model-attr-name"
      @input.should.have.value "foo bar baz"
      @input.should.have.attr "type", "hidden"


  context "label tag", ->

    it "renders label tag", ->
      I18n.t.withArgs("property.prop_value").returns "Value"
      markup = @helper "property", "propValue", null
      input = $(markup)
      input.should.have "label"
      label = input.find "label"
      label.should.have.text "Value"
      label.should.have.attr "for", "property-prop-value"

    it "uses label from options", ->
      markup = @helper "property", "propValue", null, label: "Foo"
      input = $(markup)
      label = input.find "label"
      label.should.have.text "Foo"

  context "errors", ->

    it "renders errors", ->
      markup = @helper "property", "propValue", null, errors: [ "can't be blank" ]
      input = $(markup)
      error = input.find ".error-message"
      error.should.have.text "can't be blank"

    it "classifies input with error", ->
      markup = @helper "model", "attrName", null, errors: [ "can't be blank" ]
      input = $(markup)
      input.should.have.class "error"

    it "extracts errors from model", ->
      @model.errors = -> attrName: [ "can't be blank" ]
      markup = @helper "model", "attrName", @model
      input = $(markup)
      error = input.find ".error-message"
      error.should.have.text "can't be blank"
