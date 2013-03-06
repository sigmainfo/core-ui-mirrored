#= require spec_helper
#= require views/properties/create_property_view

describe "Coreon.Views.Properties.CreatePropertyView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Properties.CreatePropertyView
      id: 42
      property: { key: "description", value: "flower", lang: "en" }
      model: new Backbone.Model

  afterEach ->
    I18n.t.restore()

  it "is a backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  it "creates container", ->
    @view.$el.should.match ".create-property"

  describe "render()", ->

    it "can be chained", ->
      @view.render().should.equal @view

    it "renders property key", ->
      @view.render()
      @view.$el.should.have ".key"
      @view.$el.should.have ".key input"
      @view.$('.key input').val().should.equal "description"
      @view.$('.key input').attr('name').should.equal "concept[properties][42][key]"
      @view.$('.key input').attr('id').should.equal "concept_properties_42_key"

    it "renders label for property key", ->
      I18n.t.withArgs("create_property.key").returns "Property Key"
      @view.render()
      @view.$el.should.have ".key"
      @view.$el.should.have ".key label"
      @view.$('.key label').should.have.text "Property Key"
      @view.$('.key label').attr('for').should.equal "concept_properties_42_key"

    it "renders property value", ->
      @view.render()
      @view.$el.should.have ".value"
      @view.$el.should.have ".value input"
      @view.$('.value input').val().should.equal "flower"
      @view.$('.value input').attr('name').should.equal "concept[properties][42][value]"
      @view.$('.value input').attr('id').should.equal "concept_properties_42_value"

    it "renders label for property key", ->
      I18n.t.withArgs("create_property.value").returns "Property Value"
      @view.render()
      @view.$el.should.have ".value"
      @view.$el.should.have ".value label"
      @view.$('.value label').should.have.text "Property Value"
      @view.$('.value label').attr('for').should.equal "concept_properties_42_value"

    it "renders property language", ->
      @view.render()
      @view.$el.should.have ".language"
      @view.$el.should.have ".language input"
      @view.$('.language input').val().should.equal "en"
      @view.$('.language input').attr('name').should.equal "concept[properties][42][lang]"
      @view.$('.language input').attr('id').should.equal "concept_properties_42_lang"

    it "renders label for property language", ->
      I18n.t.withArgs("create_property.language").returns "Property Language"
      @view.render()
      @view.$el.should.have ".language"
      @view.$el.should.have ".language label"
      @view.$('.language label').should.have.text "Property Language"
      @view.$('.language label').attr('for').should.equal "concept_properties_42_lang"

    it "renders remove property link", ->
      I18n.t.withArgs("create_property.remove").returns "Remove Property"
      @view.render()
      @view.$el.should.have "a.remove_property"
      @view.$('a.remove_property').should.have.text "Remove Property"

  describe "changes on inputs", ->

    beforeEach ->
      @view.render()

    describe "on key change", ->

      it "triggers input_changed()", ->
        @view.input_changed = sinon.spy()
        @view.delegateEvents()
        @view.$('.key input').trigger("change")
        @view.input_changed.should.have.been.called.once

      it "triggers change:properties", ->
        @view.model.get = sinon.stub().returns 42: {}
        spy = sinon.spy()
        @view.model.on "change:properties", spy
        @view.$('.key input').trigger("change")
        spy.should.have.been.called.once

      it "triggers no change:properties if key unchanged", ->
        @view.model.get = sinon.stub().returns 42: { key: "description" }
        spy = sinon.spy()
        @view.model.on "change:properties", spy
        @view.$('.key input').trigger("change")
        spy.should.not.have.been.called

      it "saves to model", ->
        @view.model.get = sinon.stub().returns 42: {}
        @view.model.set = sinon.spy()
        @view.$('.key input').val( "new_description" )
        @view.$('.key input').trigger("change")
        @view.model.set.withArgs( "properties", { 42: { key:"new_description" } } ).should.have.been.called.once

    describe "on value change", ->

      it "triggers input_changed() on value change", ->
        @view.input_changed = sinon.spy()
        @view.delegateEvents()
        @view.$('.value input').trigger("change")
        @view.input_changed.should.have.been.called.once

      it "triggers change:properties", ->
        @view.model.get = sinon.stub().returns 42: {}
        spy = sinon.spy()
        @view.model.on "change:properties", spy
        @view.$('.value input').trigger("change")
        spy.should.have.been.called.once

      it "triggers no change:properties if value unchanged", ->
        @view.model.get = sinon.stub().returns 42: { value: "flower" }
        spy = sinon.spy()
        @view.model.on "change:properties", spy
        @view.$('.value input').trigger("change")
        spy.should.not.have.been.called

      it "saves to model", ->
        @view.model.get = sinon.stub().returns 42: {}
        @view.model.set = sinon.spy()
        @view.$('.value input').val( "flower power" )
        @view.$('.value input').trigger("change")
        @view.model.set.withArgs( "properties", { 42: { value: "flower power" } } ).should.have.been.called.once

    describe "on language change", ->

      it "triggers input_changed() on language change", ->
        @view.input_changed = sinon.spy()
        @view.delegateEvents()
        @view.$('.language input').trigger("change")
        @view.input_changed.should.have.been.called.once

      it "triggers change:properties", ->
        @view.model.get = sinon.stub().returns 42: {}
        spy = sinon.spy()
        @view.model.on "change:properties", spy
        @view.$('.language input').trigger("change")
        spy.should.have.been.called.once

      it "triggers no change:properties if language unchanged", ->
        @view.model.get = sinon.stub().returns 42: { lang: "en" }
        spy = sinon.spy()
        @view.model.on "change:properties", spy
        @view.$('.language input').trigger("change")
        spy.should.not.have.been.called

      it "saves to model", ->
        @view.model.get = sinon.stub().returns 42: {}
        @view.model.set = sinon.spy()
        @view.$('.language input').val( "de" )
        @view.$('.language input').trigger("change")
        @view.model.set.withArgs( "properties", { 42: { lang: "de" } } ).should.have.been.called.once

  describe "remove property", ->

    beforeEach ->
      @view.render()

    it "triggers remove_property() on 'Remove Property' button click", ->
      @view.remove_property = sinon.spy()
      @view.delegateEvents()
      @view.$('.remove_property').click()
      @view.remove_property.should.have.been.called.once

    it "removes itself from the model", ->
      @view.options.id = 1
      properties =  [ "foo", @view.model, "bar" ]
      @view.model.get = sinon.stub().returns properties
      @view.$('.remove_property').click()
      properties.should.eql [ "foo", "bar" ]

    it "triggers change and remove events on the model", ->
      @view.options.id = 1
      properties =  [ "foo", @view.model, "bar" ]
      @view.model.get = sinon.stub().returns properties
      spy1 = sinon.spy()
      spy2 = sinon.spy()
      @view.model.on "change:properties", spy1
      @view.model.on "remove:properties", spy2
      @view.delegateEvents()
      @view.$('.remove_property').click()
      properties.should.eql [ "foo", "bar" ]
      spy1.should.be.called.once
      spy2.should.be.called.once

