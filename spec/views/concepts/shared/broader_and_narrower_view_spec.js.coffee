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
    beforeEach ->
      @repo = new Backbone.Model
      @session = new Backbone.Model
      @session.currentRepository = => @repo
      Coreon.application = new Backbone.Model session: @session

      @view.model.id = "1234"

    it "creates empty array for broader concepts", ->
      should.exist @view.broader
      @view.broader.should.be.an.instanceof Array
      @view.broader.should.have.lengthOf 0

    it "creates empty array for narrower concepts", ->
      should.exist @view.narrower
      @view.narrower.should.be.an.instanceof Array
      @view.narrower.should.have.lengthOf 0

    it "makes drop zones available in edit mode", ->
      should.exist @view.$(".broader.ui-droppable").data("uiDroppable")
      should.exist @view.$(".narrower.ui-droppable").data("uiDroppable")
      should.not.exist @view.$(".broader.static").data("uiDroppable")
      should.not.exist @view.$(".narrower.static").data("uiDroppable")

    it "denies existing broader concepts for dropping", ->
      acceptance = @view.$(".broader.ui-droppable").data("uiDroppable").options.accept
      acceptance.should.be.a "function"

    context "drag and dro", ->
      before ->
        @el_broad = $("<div>").data("drag-ident", "c0ffee")
        @el_narrow = $("<div>").data("drag-ident", "deadbeef")
        @el_foreign = $("<div>").data("drag-ident", "baffee")
        @el_own = $("<div>").data("drag-ident", @view.model.id)

      beforeEach ->
        @view.model.set "super_concept_ids", ["c0ffee"], silent: true
        @view.model.set "sub_concept_ids", ["deadbeef"], silent: true

      afterEach ->
        @view.model.set "super_concept_ids", [], silent: true
        @view.model.set "sub_concept_ids", [], silent: true

      it "denies existing narrower concepts for dropping", ->
        acceptance = @view.$(".narrower.ui-droppable").data("uiDroppable").options.accept
        acceptance.should.be.a "function"
        acceptance(@el_narrow).should.be.false

      it "denies existing broader concepts for dropping", ->
        acceptance = @view.$(".broader.ui-droppable").data("uiDroppable").options.accept
        acceptance.should.be.a "function"
        acceptance(@el_broad).should.be.false

      it "denies drop to narrower if broader is existing and vice versa", ->
        acceptance1 = @view.$(".broader.ui-droppable").data("uiDroppable").options.accept
        acceptance1(@el_narrow).should.be.false
        acceptance2 = @view.$(".narrower.ui-droppable").data("uiDroppable").options.accept
        acceptance2(@el_broad).should.be.false

      it "denies itself for dropping", ->
        acceptance1 = @view.$(".broader.ui-droppable").data("uiDroppable").options.accept
        acceptance1(@el_own).should.be.false
        acceptance2 = @view.$(".narrower.ui-droppable").data("uiDroppable").options.accept
        acceptance2(@el_own).should.be.false

      it "accepts non-existing concepts", ->
        acceptance1 = @view.$(".broader.ui-droppable").data("uiDroppable").options.accept
        acceptance2 = @view.$(".narrower.ui-droppable").data("uiDroppable").options.accept
        acceptance1(@el_foreign).should.be.true
        acceptance2(@el_foreign).should.be.true

    context "rendering markup skeleton", ->

      beforeEach ->
        sinon.stub Coreon.Helpers, "can", -> false

      afterEach ->
        Coreon.Helpers.can.restore()

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
      sinon.stub Coreon.Views.Concepts, "ConceptLabelView", (options) =>
        @label = new Backbone.View model: options.model
        @label.render = sinon.stub().returns @label
        @label

    afterEach ->
      Coreon.Models.Concept.find.restore()
      Coreon.Views.Concepts.ConceptLabelView.restore()

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
        @view.$(".broader.static ul li").should.have.lengthOf 3
        @view.$(".broader.ui-droppable ul li").should.have.lengthOf 3

      it "renders concept label into list item", ->
        @view.model.set "super_concept_ids", [ "c1" ], silent: true
        @view.render()
        # one for static and one for dropzone
        Coreon.Views.Concepts.ConceptLabelView.should.have.been.calledTwice
        Coreon.Views.Concepts.ConceptLabelView.should.have.been.calledWithNew
        @label.render.should.have.been.calledOnce
        ( $.contains @view.el, @label.el ).should.be.true

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
          @repo.set
            _id: "coffeebabe23"
            name: "delicious data"
          @view.model.set "super_concept_ids", [], silent: true

        it "renders repository node", ->
          @view.render()
          @view.$(".broader ul").should.have "li a.repository-label"
          @view.$(".broader.static .repository-label").should.have.attr "href", "/coffeebabe23"
          @view.$(".broader.static .repository-label").should.have.text "delicious data"
          @view.$(".broader.ui-droppable .repository-label").should.have.attr "href", "/coffeebabe23"
          @view.$(".broader.ui-droppable .repository-label").should.have.text "delicious data"

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
        @view.$(".narrower.static ul li").should.have.lengthOf 3
        @view.$(".narrower.ui-droppable ul li").should.have.lengthOf 3

      it "renders concept label into list item", ->
        @view.model.set "sub_concept_ids", [ "c1" ], silent: true
        @view.render()
        # one for static and one for dropzone
        Coreon.Views.Concepts.ConceptLabelView.should.have.been.calledTwice
        Coreon.Views.Concepts.ConceptLabelView.should.have.been.calledWithNew
        @label.render.should.have.been.calledOnce
        ( $.contains @view.el, @label.el ).should.be.true

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

      
      
