#= require spec_helper
#= require helpers/fields_for

describe "Coreon.Helpers.fields_for()", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @model = new Backbone.Model
    @helper = Coreon.Helpers.fields_for

  afterEach ->
    I18n.t.restore()

  it "wraps block with section tag", ->
    markup = @helper "myAttribute", @model, -> '<input type="text" name="title" value="Wahappan?"/>'
    set = $(markup)
    set.should.match "section.my-attribute"
    set.should.have 'input[type="text"][name="title"][value="Wahappan?"]'
