#= require spec_helper
#= require views/properties/properties_view

describe "Coreon.Views.Properties.PropertiesView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Properties.PropertiesView
      model: new Backbone.Model
        properties: []

  afterEach ->
    I18n.t.restore()

  it "is a section view", ->
    @view.should.be.an.instanceof Coreon.Views.Layout.SectionView

  it "creates container", ->
    @view.$el.should.have.class "properties"    

  describe "#render", ->

    it "can be chained", ->
      @view.render().should.equal @view
  
    it "renders title", ->
      I18n.t.withArgs("properties.title").returns("Properties")
      @view.render()
      @view.$el.should.have ".section-toggle"
      @view.$(".section-toggle").should.have.text "Properties"

    it "renders table row for each key", ->
      @view.model.set "properties", [
        { key: "definition" , value: "A portable weapon"    }
        { key: "definition" , value: "Tragbare Schusswaffe" }
        { key: "notes"      , value: "DO NOT USE!"          }
      ], silent: true
      @view.render()
      @view.$(".section table tr").size().should.equal 2
      @view.$(".section table tr th").eq(0).should.have.text "definition"
      @view.$(".section table tr th").eq(1).should.have.text "notes"


    context " single value for key", ->

      beforeEach ->
        @view.model.set "properties", [
          {key: "notes", value: "DO NOT USE!"}
        ], silent: true

      it "renders value as plain text", ->
        @view.model.set "properties", [
          {key: "notes", value: "DO NOT USE!"}
        ], silent: true
        @view.render()
        @view.$("tr td").eq(0).should.have.text "DO NOT USE!"

      it "renders lang when given", ->
        @view.model.set "properties", [
          {key: "notes", value: "DO NOT USE!", lang: "en"}
        ], silent: true
        @view.render()
        @view.$("tr td").eq(0).should.have "ul.index"
        @view.$("ul.index li a").eq(0).should.have.text "en"
        @view.$("ul.values li").eq(0).should.have.text "DO NOT USE!"

    context "multiple values for key", ->
     
      beforeEach ->
        @view.model.set "properties", [
          {key: "notes", value: "DO NOT USE!"}
          {key: "notes", value: "I MEAN IT!", lang: "en"}
        ], silent: true

      it "renders list of values", ->
        @view.render()
        @view.$("tr td").should.have "ul.values"
        @view.$("ul.values li").eq(0).should.have.text "DO NOT USE!"
        @view.$("ul.values li").eq(1).should.have.text "I MEAN IT!"

      it "renders index", ->
        @view.render()
        @view.$("tr td").eq(0).should.have "ul.index"
        @view.$("ul.index li a").eq(0).should.have.text "1"
        @view.$("ul.index li a").eq(0).should.have.attr "data-index", "0"
        @view.$("ul.index li a").eq(1).should.have.text "en"
        @view.$("ul.index li a").eq(1).should.have.attr "data-index", "1"

      it "selects first value", ->
        $("#konacha").append @view.render().$el
        @view.$("ul.index li").eq(0).should.have.class "selected"
        @view.$("ul.index li").eq(1).should.not.have.class "selected"
        @view.$("ul.values li").eq(0).should.be.visible 
        @view.$("ul.values li").eq(1).should.not.be.visible 


  describe "#select", ->

    beforeEach ->
      @view.model.set "properties", [
        { key: "definition" , value: "A portable weapon"    }
        { key: "definition" , value: "Tragbare Schusswaffe" }
      ], silent: true
      @view.render()

    it "is triggered by click on index item", ->
      @view.select = sinon.spy()
      @view.delegateEvents()
      @view.$("ul.index a").first().click()
      @view.select.should.have.been.calledOnce

    it "hides all but selected", ->
      $("#konacha").append @view.$el
      @view.$("ul.index a").eq(1).click()
      @view.$("ul.values li").eq(1).should.be.visible
      @view.$("ul.values li").eq(0).should.not.be.visible

    it "marks selected index item", ->
      @view.$("ul.index a").eq(1).click()
      @view.$("ul.index li").eq(1).should.have.class "selected"
      @view.$("ul.index li").eq(0).should.not.have.class "selected"
