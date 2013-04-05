#= require spec_helper
#= require views/concepts/shared/broader_and_narrower_view

describe "Coreon.Views.Concepts.Shared.BroaderAndNarrowerView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: new Backbone.Model
        super_concept_ids: []
        sub_concept_ids: []

  afterEach ->
    I18n.t.restore()

  it "is a Backbone view", ->
   @view.should.be.an.instanceof Backbone.View

  it "is classified", ->
    @view.$el.should.have.class "broader-and-narrower"

  it "is a section", ->
    @view.$el.should.be "section"

  describe "initialize()", ->

    it "creates empty array for broader concepts", ->
      should.exist @view.broader
      @view.broader.should.be.an.instanceof Array
      @view.broader.should.have.lengthOf 0

    it "creates empty array for narrower concepts", ->
      should.exist @view.narrower
      @view.narrower.should.be.an.instanceof Array
      @view.narrower.should.have.lengthOf 0

    context "rendering markup skeleton", ->

      it "renders section header", ->
        I18n.t.withArgs("concept.broader_and_narrower").returns "Broader & Narrower"
        @view.initialize()
        @view.$el.should.have "h3"
        @view.$("h3").should.have.text "Broader & Narrower"

      it "renders container for itself", ->
        @view.render()
        @view.$el.should.have ".self"

      it "renders container for broader concepts", ->
        @view.render()
        @view.$el.should.have ".broader ul"
        
      it "renders container for narrower concepts", ->
        @view.render()
        @view.$el.should.have ".narrower ul"

      it "renders container for toggling", ->
        @view.render()
        container = @view.$("h3").next()
        container.should.have ".self" 
        container.should.have ".broader" 
        container.should.have ".narrower" 

  describe "render()", ->

    beforeEach ->
      concepts = {}
      sinon.stub Coreon.Models.Concept, "find", (id) ->
        concepts[id] ?= new Backbone.Model _id: id

    afterEach ->
      Coreon.Models.Concept.find.restore()

    it "can be chained", ->
      @view.render().should.equal @view

    context "itself", ->
      
      it "renders label", ->
        @view.model.set "label", "Whahappan?", silent: true
        @view.render()
        @view.$(".self").should.have.text "Whahappan?"
  
      it "escapes label", ->
        @view.model.set "label", "<script>evil()</script>", silent: true
        @view.render()
        @view.$(".self").should.have.html "&lt;script&gt;evil()&lt;/script&gt;"

      it "rerenders on model change", ->
        @view.model.set "label", "Whahappan?", silent: true
        @view.render()
        @view.model.set "label", "wha happen!"
        @view.$(".self").should.have.text "wha happen!"

    context "broader", ->

      it "creates concept label view", ->
        @view.model.set "super_concept_ids", [ "c1", "c2", "c3" ], silent: true
        @view.render()
        @view.broader.should.have.lengthOf 3
        ( view.model.id for view in @view.broader ).should.eql [ "c1", "c2", "c3" ]

      it "removes old concept label views", ->
        parent = remove: sinon.spy()
        @view.broader = [ parent ]
        @view.render()
        parent.remove.should.have.been.calledOnce 

      it "creates list item for every concept", ->
        @view.model.set "super_concept_ids", [ "c1", "c2", "c3" ], silent: true
        @view.render()
        @view.$(".broader ul li").should.have.lengthOf 3

      it "renders concept label into list item", ->
        $el = $ '<a class="concept-label">'
        label = render: sinon.stub().returns $el: $el
        sinon.stub Coreon.Views.Concepts, "ConceptLabelView", -> label
        try
          @view.model.set "super_concept_ids", [ "c1" ], silent: true
          @view.render()
          label.render.should.have.been.calledOnce
          ( $.contains @view.el, $el.get 0 ).should.be.true
        finally
          Coreon.Views.Concepts.ConceptLabelView.restore()

      it "removes old list items", ->
        @view.model.set "super_concept_ids", [], silent: true
        @view.$(".broader ul").append $('<li class="legacy">')
        @view.render()
        @view.$(".broader ul li.legacy").should.have.lengthOf 0

      it "rerenders items on model change", ->
        @view.model.set "super_concept_ids", [ "c1", "c2", "c3" ], silent: true
        @view.render()
        @view.model.set "super_concept_ids", [ "c45" ]
        @view.broader.should.have.lengthOf 1
        ( $.contains @view.el, @view.broader[0].el ).should.be.true

      context "with empty super concepts list", ->
        
        beforeEach ->
          @view.model.set "super_concept_ids", [], silent: true

        it "renders repository node", ->
          I18n.t.withArgs("repository.label").returns "Repository"
          @view.render()
          @view.$(".broader ul").should.have "li a.repository-label"
          @view.$(".broader .repository-label").should.have.attr "href", "/"
          @view.$(".broader .repository-label").should.have.text "Repository"

        it "does not render repository when blank", ->
          @view.model.blank = true
          @view.render()
          @view.$(".broader ul").should.not.have "li .repository-label"

        it "rerenders on blank state change", ->
          @view.model.blank = true
          @view.render()
          @view.model.blank = false
          @view.model.trigger "nonblank"
          @view.$(".broader ul").should.have "li .repository-label"
          

    context "narrower", ->

      it "creates concept label view", ->
        @view.model.set "sub_concept_ids", [ "c1", "c2", "c3" ], silent: true
        @view.render()
        @view.narrower.should.have.lengthOf 3
        ( view.model.id for view in @view.narrower ).should.eql [ "c1", "c2", "c3" ]

      it "removes old concept label views", ->
        child = remove: sinon.spy()
        @view.narrower = [ child ]
        @view.render()
        child.remove.should.have.been.calledOnce 

      it "creates list item for every concept", ->
        @view.model.set "sub_concept_ids", [ "c1", "c2", "c3" ], silent: true
        @view.render()
        @view.$(".narrower ul li").should.have.lengthOf 3

      it "renders concept label into list item", ->
        $el = $ '<a class="concept-label">'
        label = render: sinon.stub().returns $el: $el
        sinon.stub Coreon.Views.Concepts, "ConceptLabelView", -> label
        try
          @view.model.set "sub_concept_ids", [ "c1" ], silent: true
          @view.render()
          label.render.should.have.been.calledOnce
          ( $.contains @view.el, $el.get 0 ).should.be.true
        finally
          Coreon.Views.Concepts.ConceptLabelView.restore()

      it "removes old list items", ->
        @view.model.set "sub_concept_ids", [], silent: true
        @view.$(".narrower ul").append $("<li>")
        @view.render()
        @view.$(".narrower ul li").should.have.lengthOf 0

      it "rerenders items on model change", ->
        @view.model.set "sub_concept_ids", [ "c1", "c2", "c3" ], silent: true
        @view.render()
        @view.model.set "sub_concept_ids", [ "c45" ]
        @view.narrower.should.have.lengthOf 1
        ( $.contains @view.el, @view.narrower[0].el ).should.be.true

  describe "remove()", ->
    
    beforeEach ->
      sinon.stub Backbone.View::, "remove", -> @

    afterEach ->
      Backbone.View::remove.restore()

    it "can be chain", ->
      @view.remove().should.equal @view

    it "removes concepts", ->
      parent = remove: sinon.spy()
      child  = remove: sinon.spy()
      @view.broader = [ parent ]
      @view.narrower = [ child ]
      @view.remove()
      parent.remove.should.have.been.calledOnce
      child.remove.should.have.been.calledOnce

    it "calls super", ->
      @view.remove()
      Backbone.View::remove.should.have.been.calledOn @view

      
      
