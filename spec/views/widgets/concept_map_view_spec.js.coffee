#= require spec_helper
#= require views/widgets/concept_map_view

describe "Coreon.Views.Widgets.ConceptMapView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Widgets.ConceptMapView

  afterEach ->
    I18n.t.restore()

  it "is a simple view", ->
    @view.should.be.an.instanceof Coreon.Views.SimpleView

  it "creates container", ->
    @view.$el.should.have.id "coreon-concept-map"
    @view.$el.should.have.class "widget"

  describe "#render", ->
  
    it "can be chained", ->
      @view.render().should.equal @view

    it "renders titlebar", ->
      I18n.t.withArgs("concept-map.title").returns "Concept Map"
      @view.render()
      @view.$el.should.have ".titlebar h4"
      @view.$(".titlebar h4").should.have.text "Concept Map"

    it "renders viewport", ->
      @view.render()
      @view.$el.should.have "svg"

