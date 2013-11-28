#= require spec_helper
#= require views/search/search_results_concepts_view
#= require config/application

describe "Coreon.Views.Search.SearchResultsConceptsView", ->

  beforeEach ->
    Coreon.Modules.CoreAPI.sync = ->
    Coreon.Helpers.repositoryPath = (s)-> "/coffee23/"+s
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Search.SearchResultsConceptsView model: new Backbone.Model(hits: [])
    @view.model.query = -> "foo"

  afterEach ->
    I18n.t.restore()

  it "is a composite view", ->
    @view.should.be.an.instanceof Coreon.Views.CompositeView

  it "creates container", ->
    @view.$el.should.have.class "search-results-concepts"

  describe "render()", ->

    beforeEach ->
      sinon.stub Coreon.Models.Concept, 'find'
      Coreon.Models.Concept.find.returns new Backbone.Model
        superconcept_ids: []
      Coreon.Helpers.can = -> true

    afterEach ->
      Coreon.Models.Concept.find.restore()

    it "is chainable", ->
      @view.render().should.equal @view

    it "renders headline", ->
      I18n.t.withArgs("search.results.concepts.headline").returns "Concepts"
      @view.render()
      @view.$el.should.have "h3"
      @view.$("h3").should.have.text "Concepts"

    it "renders table header", ->
      I18n.t.withArgs("search.results.concepts.header.label").returns "Label"
      I18n.t.withArgs("search.results.concepts.header.superconcepts").returns "Superconcepts"
      @view.render()
      @view.$el.should.have "table.concepts"
      @view.$(".concepts th").eq(0).should.have.text "Label"
      @view.$(".concepts th").eq(1).should.have.text "Superconcepts"

    it "renders concepts", ->
      Coreon.Models.Concept.find.withArgs('503e248cd198795712000005').returns new Backbone.Model
          id: '503e248cd198795712000005'
          superconcept_ids: [ '503e248cd198795712000002', '504e248cd198795712000042' ]
          label: 'My Concept'
      Coreon.Models.Concept.find.withArgs('503e248cd198795712000002').returns new Backbone.Model
        id: '503e248cd198795712000002'
      Coreon.Models.Concept.find.withArgs('504e248cd198795712000042').returns new Backbone.Model
        id: '504e248cd198795712000042'
      @view.model.set 'hits', [ result: id: '503e248cd198795712000005' ], silent: yes
      @view.render()
      @view.$(".concepts tbody tr:first td.label").should.have "a[href='/coffee23/concepts/503e248cd198795712000005']"
      @view.$("a[href='/coffee23/concepts/503e248cd198795712000005']").should.have.text "My Concept"
      @view.$(".concepts tbody tr:first td.super").should.have "a.concept-label[href='/coffee23/concepts/503e248cd198795712000002']"
      @view.$(".concepts tbody tr:first td.super").should.have "a.concept-label[href='/coffee23/concepts/504e248cd198795712000042']"

    it 'is rendered on concept label changes', ->
      concept = new Backbone.Model
          id: '503e248cd198795712000005'
          superconcept_ids: []
          label: 'My Concept'
      Coreon.Models.Concept.find.withArgs('503e248cd198795712000005').returns concept
      @view.model.set 'hits', [ result: id: '503e248cd198795712000005' ], silent: yes
      @view.render()
      concept.set 'label', 'Changed Concept'
      expect( @view.$el.text() ).to.include 'Changed Concept'

    it "renders top 10 concepts only", ->
      @view.model.set "hits",
        for n in [1..25]
          result:
            id: "503e248cd198795712000005"
            properties: [
              key: "label"
              value: "poet"
            ]
            superconcept_ids: []
      @view.render()
      @view.$("tbody tr").length.should.equal 10

    it 'sorts concept list by score and label', ->
      Coreon.Models.Concept.find.withArgs('top_hit').returns new Backbone.Model
        id               : 'top_hit'
        label            : 'Zebra'
        superconcept_ids : []
      Coreon.Models.Concept.find.withArgs('not_so_top_hit').returns new Backbone.Model
        id               : 'not_so_top_hit'
        label            : 'Affe'
        superconcept_ids : []
      Coreon.Models.Concept.find.withArgs('other_top_hit').returns new Backbone.Model
        id               : 'other_top_hit'
        label            : 'Pelikan'
        superconcept_ids : []
      @view.model.set 'hits', [
        { result: { id: 'top_hit'        }, score: 100 }
        { result: { id: 'not_so_top_hit' }, score: 0.1 }
        { result: { id: 'other_top_hit'  }, score: 100 }
      ], silent: yes
      @view.render()
      expect( @view.$('tbody tr:nth-child(1) td.label') ).to.have.text 'Pelikan'
      expect( @view.$('tbody tr:nth-child(2) td.label') ).to.have.text 'Zebra'
      expect( @view.$('tbody tr:nth-child(3) td.label') ).to.have.text 'Affe'

    it "is triggered on model change", ->
      @view.render = sinon.spy()
      @view.initialize()
      @view.model.trigger "change"
      @view.render.should.have.been.calledOnce

    it "renders link to complete list", ->
      I18n.t.withArgs("search.results.concepts.show_all").returns "Show all"
      @view.model.query = -> "gun"
      @view.render()
      @view.$el.should.have "a.show-all"
      @view.$("a.show-all").should.have.text "Show all"
      @view.$("a.show-all").should.have.attr "href", "/coffee23/concepts/search/gun"

    context "with maintainer privileges", ->

      beforeEach ->
        Coreon.Helpers.can = -> true

      it "renders link to new concept form", ->
        I18n.t.withArgs("concept.new").returns "New concept"
        @view.model.query = -> "poet"
        @view.render()
        @view.$el.should.have 'a[href="/coffee23/concepts/new/terms/en/poet"]'
        @view.$('a[href="/coffee23/concepts/new/terms/en/poet"]').should.have.text "New concept"


    context "without maintainer privileges", ->

      beforeEach ->
        Coreon.Helpers.can = -> false

      it "renders link to new concept form", ->
        @view.render()
        @view.$el.should.not.have 'a[href="/coffee23/concepts/new"]'

