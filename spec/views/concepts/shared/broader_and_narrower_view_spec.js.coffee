#= require spec_helper
#= require views/concepts/shared/broader_and_narrower_view

describe "Coreon.Views.Concepts.Shared.BroaderAndNarrowerView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    sinon.stub(Coreon.Helpers, "can").returns true
    model = new Backbone.Model
      super_concept_ids: []
      sub_concept_ids: []
    model.acceptsConnection = -> true
    @view = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView model: model

  afterEach ->
    I18n.t.restore()
    Coreon.Helpers.can.restore()

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
      @view.initialize()


    it "creates empty array for broader concepts", ->
      should.exist @view.broader
      @view.broader.should.be.an.instanceof Array
      @view.broader.should.have.lengthOf 0

    it "creates empty array for narrower concepts", ->
      should.exist @view.narrower
      @view.narrower.should.be.an.instanceof Array
      @view.narrower.should.have.lengthOf 0

    context "rendering markup skeleton", ->

      beforeEach ->
        Coreon.Helpers.can.returns false

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
        container = @view.$("h3").siblings("form")
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

      it "renders concept label into list item", ->
        @view.model.set "super_concept_ids", [ "c1" ], silent: true
        @view.render()
        # one for static and one for dropzone
        Coreon.Views.Concepts.ConceptLabelView.should.have.been.calledTwice
        Coreon.Views.Concepts.ConceptLabelView.should.have.been.calledWithNew
        @label.render.should.have.been.calledOnce
        @view.$el.find("[data-drag-ident=c1]").length.should.equal 1

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
        @view.$el.find("[data-drag-ident=c45]").length.should.equal 1

      context "with empty super concepts list", ->
        
        beforeEach ->
          @repo.set
            _id: "coffeebabe23"
            name: "delicious data"
          @view.model.set "super_concept_ids", [], silent: true
          @view.model.isNew = -> false
          @view.initialize()

        it "renders repository node", ->
          @view.render()
          @view.$(".broader.static ul").should.have "li a.repository-label"
          @view.$(".broader.static .repository-label").should.have.attr "href", "/coffeebabe23"
          @view.$(".broader.static .repository-label").should.have.text "delicious data"

        it "renders no repository node in droppable", ->
          @view.render()
          @view.$(".broader.ui-droppbale ul").should.not.have "li a.repository-label"

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

      it "renders concept label into list item", ->
        @view.model.set "sub_concept_ids", [ "c1" ], silent: true
        @view.render()
        # one for static and one for dropzone
        Coreon.Views.Concepts.ConceptLabelView.should.have.been.calledTwice
        Coreon.Views.Concepts.ConceptLabelView.should.have.been.calledWithNew
        @label.render.should.have.been.calledOnce
        @view.$el.find("[data-drag-ident=c1]").length.should.equal 1

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

      
  describe "toggleEditMode()", ->
    beforeEach ->
      @view.model.id = "1234"
      @view.model.isNew = -> false
 
    context "outside edit mode", ->

      beforeEach ->
        @view.initialize()
        @view.render()

      it "creates no drop zones", ->
        should.not.exist @view.$(".broader.ui-droppable").data("uiDroppable")
        should.not.exist @view.$(".narrower.ui-droppable").data("uiDroppable")
        should.not.exist @view.$(".broader.static").data("uiDroppable")
        should.not.exist @view.$(".narrower.static").data("uiDroppable")

    context "inside edit mode", ->
      before ->
        @el_broad = $("<div data-drag-ident='c0ffee'>")
        @el_narrow = $("<div data-drag-ident='deadbeef'>")
        @el_foreign = $("<div data-drag-ident='bad1dea'>")
        @el_own = $("<div data-drag-ident='#{@view.model.id}'>")

      beforeEach ->
        sinon.stub @view, "createConcept", ->
          new Backbone.View model: new Backbone.Model

        @view.model.set "super_concept_ids", ["c0ffee"], silent: true
        @view.model.set "sub_concept_ids", ["deadbeef"], silent: true

        @view.initialize()
        @view.render()
        @view.$(".broader ul").append $("<li>").append @el_broad
        @view.$(".narrower ul").append $("<li>").append @el_narrow

        @view.toggleEditMode()

      afterEach ->
        @view.model.set "super_concept_ids", [], silent: true
        @view.model.set "sub_concept_ids", [], silent: true


      it "makes drop zones available", ->
        should.exist @view.$(".broader.ui-droppable").data("uiDroppable")
        should.exist @view.$(".narrower.ui-droppable").data("uiDroppable")
        should.not.exist @view.$(".broader.static").data("uiDroppable")
        should.not.exist @view.$(".narrower.static").data("uiDroppable")

      it "denies existing broader concepts for dropping", ->
        acceptance = @view.$(".broader.ui-droppable").data("uiDroppable").options.accept
        acceptance.should.be.a "function"

      it "temporary connects broader concept", ->
        dropFun = @view.$(".broader.ui-droppable").data("uiDroppable").options.drop
        dropFun.should.be.a "function"
        dropFun new $.Event, helper: @el_foreign
        item = @view.$(".broader.ui-droppable ul li [data-drag-ident=bad1dea]")
        should.exist item
        should.exist item.siblings("input[type=hidden]")
        item.siblings("input[type=hidden]").attr("name").should.equal "super_concept_ids[]"
        item.siblings("input[type=hidden]").attr("value").should.equal "bad1dea"

      it "temporary connects narrower concept", ->
        dropFun = @view.$(".narrower.ui-droppable").data("uiDroppable").options.drop
        dropFun.should.be.a "function"
        dropFun new $.Event, helper: @el_foreign
        item = @view.$(".narrower.ui-droppable ul li [data-drag-ident=bad1dea]")
        should.exist item
        should.exist item.siblings("input[type=hidden]")
        item.siblings("input[type=hidden]").attr("name").should.equal "sub_concept_ids[]"
        item.siblings("input[type=hidden]").attr("value").should.equal "bad1dea"

      it "denies temporary connected broader concepts", ->
        dropFun = @view.$(".broader.ui-droppable").data("uiDroppable").options.drop
        dropFun new $.Event, helper: @el_foreign
        acceptance1 = @view.$(".broader.ui-droppable").data("uiDroppable").options.accept
        acceptance2 = @view.$(".narrower.ui-droppable").data("uiDroppable").options.accept
        acceptance1(@el_foreign).should.be.false
        acceptance2(@el_foreign).should.be.false

      it "denies temporary connected narrower concepts", ->
        dropFun = @view.$(".narrower.ui-droppable").data("uiDroppable").options.drop
        dropFun new $.Event, helper: @el_foreign
        acceptance1 = @view.$(".broader.ui-droppable").data("uiDroppable").options.accept
        acceptance2 = @view.$(".narrower.ui-droppable").data("uiDroppable").options.accept
        acceptance1(@el_foreign).should.be.false
        acceptance2(@el_foreign).should.be.false

      it "accepts non-existing concepts", ->
        acceptance1 = @view.$(".broader.ui-droppable").data("uiDroppable").options.accept
        acceptance2 = @view.$(".narrower.ui-droppable").data("uiDroppable").options.accept
        acceptance1(@el_foreign).should.be.true
        acceptance2(@el_foreign).should.be.true

