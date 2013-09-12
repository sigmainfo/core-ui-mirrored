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
    model.url = "/concepts/123"
    model.concept = model

    Coreon.Models.BroaderAndNarrowerForm = -> model
    @view = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView model: model
    concepts = {}
    sinon.stub Coreon.Models.Concept, "find", (id) ->
      concepts[id] ?= new Backbone.Model _id: id, label: id

  afterEach ->
    I18n.t.restore()
    Coreon.Helpers.can.restore()
    Coreon.Models.Concept.find.restore()

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

  describe "render()", ->

    beforeEach ->
      sinon.stub Coreon.Views.Concepts, "ConceptLabelView", (options) =>
        @label = new Backbone.View model: options.model
        @label.render = sinon.stub().returns @label
        @label

    afterEach ->
      Coreon.Views.Concepts.ConceptLabelView.restore()

    it "can be chained", ->
      @view.render().should.equal @view

    context "rendering markup skeleton", ->

      beforeEach ->
        Coreon.Helpers.can.returns false

      it "renders section header", ->
        I18n.t.withArgs("concept.broader_and_narrower").returns "Broader & Narrower"
        @view.render()
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

      it "renders form in edit mode", ->
        @view.toggleEditMode()
        container = @view.$("h3").siblings("form")
        container.should.have ".self"
        container.should.have ".broader"
        container.should.have ".narrower"


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
        @view.model.set "super_concept_ids", [ "c1" ], silent: true
        @view.render()
        Coreon.Views.Concepts.ConceptLabelView.should.have.been.calledOnce
        Coreon.Views.Concepts.ConceptLabelView.should.have.been.calledWithNew
        @label.render.should.have.been.calledOnce
        @view.$el.find(".broader ul li [data-drag-ident=c1]").length.should.equal 1

      it "removes old list items", ->
        @view.model.set "super_concept_ids", [], silent: true
        @view.$(".broader ul").append $('<li class="legacy">')
        @view.render()
        @view.$(".broader ul li.legacy").should.have.lengthOf 0

      xit "rerenders items on model change", ->
        @view.model.set "super_concept_ids", [ "c1", "c2", "c3" ], silent: true
        @view.render()
        @view.model.set "super_concept_ids", [ "c45" ]
        #TODO: needs to handle defered rendering (_.defer)
        @view.$("[data-drag-ident=c1]").length.should.equal 0
        @view.$("[data-drag-ident=c45]").length.should.equal 1

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
          @view.$(".broader ul").should.have "li a.repository-label"
          @view.$(".broader .repository-label").should.have.attr "href", "/coffeebabe23"
          @view.$(".broader .repository-label").should.have.text "delicious data"

        it "renders no repository node in droppable", ->
          @view.toggleEditMode()
          @view.$("form .broader ul").should.not.have ".repository-label"

        it "does not render repository when blank", ->
          @view.model.blank = true
          @view.render()
          @view.$(".broader ul").should.not.have ".repository-label"

        xit "rerenders on blank state change", ->
          @view.model.blank = true
          @view.render()
          @view.model.blank = false
          @view.model.trigger "nonblank"
          #TODO: needs to handle defered rendering (_.defer)
          @view.$(".broader ul").should.have ".repository-label"
          

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
        @view.model.set "sub_concept_ids", [ "c1" ], silent: true
        @view.render()
        Coreon.Views.Concepts.ConceptLabelView.should.have.been.calledOnce
        Coreon.Views.Concepts.ConceptLabelView.should.have.been.calledWithNew
        @label.render.should.have.been.calledOnce
        @view.$el.find("[data-drag-ident=c1]").length.should.equal 1

      it "removes old list items", ->
        @view.model.set "sub_concept_ids", [], silent: true
        @view.$(".narrower ul").append $("<li>")
        @view.render()
        @view.$(".narrower ul li").should.have.lengthOf 0

      xit "rerenders items on model change", ->
        @view.model.set "sub_concept_ids", [ "c1", "c2", "c3" ], silent: true
        @view.render()
        @view.model.set "sub_concept_ids", [ "c45" ]
        #TODO: needs to handle defered rendering (_.defer)
        @view.narrower.should.have.lengthOf 1
        @view.$el.find("[data-drag-ident=c45]").length.should.equal 1

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

    afterEach ->
      $(window).off ".coreonSubmit"
 
    context "outside edit mode", ->

      beforeEach ->
        @view.initialize()
        @view.render()

      it "creates no drop zones", ->
        should.not.exist @view.$("form .broader ul").data("uiDroppable")
        should.not.exist @view.$("form .narrower ul").data("uiDroppable")

      it "doesn't disable concept-label links", ->
        clickEvent = $.Event "click"
        clickEvent.preventDefault = sinon.spy()
        clickEvent.stopPropagation = sinon.spy()
        @view.$(".concept-label").first().trigger clickEvent
        clickEvent.preventDefault.should.not.have.been.called
        clickEvent.stopPropagation.should.not.have.been.called

      it "does not submit form when pressing enter", ->
        spy = sinon.spy()
        @view.$("form").on "submit", spy
        event = $.Event "keydown"
        event.keyCode = 13
        $(window).trigger event
        spy.should.not.have.been.called

    context "inside edit mode", ->

      before ->
        @el_broad = $("<div data-drag-ident='c0ffee'>")
        @el_narrow = $("<div data-drag-ident='deadbeef'>")
        @el_foreign = $("<div data-drag-ident='bad1dea'>")
        @el_own = $("<div data-drag-ident='#{@view.model.id}'>")

      beforeEach ->
        sinon.stub @view, "createConcept", (id)->
          new Backbone.View model: new Backbone.Model _id:id

        @view.model.set "super_concept_ids", ["c0ffee"], silent: true
        @view.model.set "sub_concept_ids", ["deadbeef"], silent: true
        @view.model.addedBroaderConcepts = -> 0
        @view.model.addedNarrowerConcepts = -> 0
        @view.model.removedBroaderConcepts = -> 0
        @view.model.removedNarrowerConcepts = -> 0

        @view.initialize()
        @view.toggleEditMode()
        @view.$(".broader ul").html $("<li>").append @el_broad
        @view.$(".narrower ul").html $("<li>").append @el_narrow

        @dropFunBroad = @view.$("form .broader ul").data("uiDroppable").options.drop
        @dropFunNarrow = @view.$("form .narrower ul").data("uiDroppable").options.drop


      afterEach ->
        @view.model.set "super_concept_ids", [], silent: true
        @view.model.set "sub_concept_ids", [], silent: true

      it "calls preventLabelClicks on click", ->
        clickEvent = $.Event "click"
        clickEvent.preventDefault = sinon.spy()
        clickEvent.stopPropagation = sinon.spy()
        @view.$('.concept-label').trigger clickEvent
        clickEvent.preventDefault.should.have.been.calledOnce
        clickEvent.stopPropagation.should.have.been.calledOnce

      it "submits form when pressing enter", ->
        spy = sinon.spy()
        @view.$("form").on "submit", spy
        event = $.Event "keydown"
        event.keyCode = 13
        $(window).trigger event
        spy.should.have.been.calledOnce

      xit "makes drop zones available", ->
        should.exist @view.$(".broader.ui-droppable ul").data("uiDroppable")
        should.exist @view.$(".narrower.ui-droppable ul").data("uiDroppable")
        should.not.exist @view.$(".broader.static ul").data("uiDroppable")
        should.not.exist @view.$(".narrower.static ul").data("uiDroppable")

      it "has drop methods", ->
        @dropFunBroad.should.be.a.function
        @dropFunNarrow.should.be.a.function

      it "has acceptance methods", ->
        @view.$(".broader ul").data("uiDroppable").options.accept.should.be.a.function
        @view.$(".narrower ul").data("uiDroppable").options.accept.should.be.a.function

      xit "renders new connected concepts", ->
        @view.onDrop "broader", @el_foreign
        #TODO: needs to handle defered rendering (_.defer)
        @view.$(".broader [data-drag-ident=bad1dea]").should.exist

  describe "onDisconnect()", ->

    beforeEach ->
      sinon.stub @view, "createConcept", ->
        new Backbone.View model: new Backbone.Model

      @el_broad = $("<div data-drag-ident='c0ffee'>")
      @el_narrow = $("<div data-drag-ident='deadbeef'>")

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

    it "deletes items", ->
      @view.onDisconnect(@el_broad)
      @view.onDisconnect(@el_narrow)
      @view.$(".broader [data-drag-ident=c0ffee]").should.not.exist
      @view.$(".narrower [data-drag-ident=deadbeef]").should.not.exist
      @view.model.get("super_concept_ids").should.not.contain "c0ffee"
      @view.model.get("sub_concept_ids").should.not.contain "deadbeef"

    it "reconnects items", ->
      @view.onDisconnect(@el_narrow)
      @view.onDisconnect(@el_broad)
      @view.onDrop("narrower", @el_narrow)
      @view.onDrop("broader", @el_broad)


  describe "updateConceptConnections()", ->

    beforeEach ->
      @event = $.Event()
      sinon.stub @view.model, "save"

      @view.$el.html $('
        <form class="active">
          <div class="broader static">
            <ul>
              <li><div data-drag-ident="c0ffee">Coffee</div></li>
            </ul>
          </div>
          <div class="broader ui-droppable">
            <ul>
              <li><div data-drag-ident="c0ffee">Coffee</div></li>
            </ul>
          </div>
          <div class="narrower static">
            <ul>
              <li><div data-drag-ident="deadbeef">Meat</div></li>
            </ul>
          </div>
          <div class="narrower ui-droppable">
            <ul>
              <li><div data-drag-ident="deadbeef">Meat</div></li>
            </ul>
          </div>
          <div class="submit">
            <a href="#">submitaction</a>
            <button type="submit">submit</button>
          </div>
        </form>
      ')

      @view.model.set "super_concept_ids", ["c0ffee"], silent: true
      @view.model.set "sub_concept_ids", ["deadbeef"], silent: true
      @view.model.addedBroaderConcepts = -> 0
      @view.model.addedNarrowerConcepts = -> 0
      @view.model.removedBroaderConcepts = -> 0
      @view.model.removedNarrowerConcepts = -> 0
      @deferred = $.Deferred()
      @view.model.save.returns @deferred

      @view.toggleEditMode()

    afterEach ->
      @view.model.save.restore()

    it "is triggered on submit", ->
      @view.updateConceptConnections = sinon.spy()
      @view.delegateEvents()
      @view.$("form").submit()
      @view.updateConceptConnections.should.have.been.calledOnce

    xit "adds new ids", ->
      @view.$(".broader.ui-droppable ul").append $('<li><div data-drag-ident="bad1dea" data-new-connection="true"></div></li>')
      @view.$(".narrower.ui-droppable ul").append $('<li><div data-drag-ident="babee" data-new-connection="true"></div></li>')
      @view.updateConceptConnections @event
      @view.model.save.should.have.been.calledOnce
      dataArg = @view.model.save.firstCall.args[0]
      dataArg.should.be.an.object
      dataArg.super_concept_ids.should.be.an.array
      dataArg.super_concept_ids.should.contain "bad1dea"
      dataArg.sub_concept_ids.should.be.an.array
      dataArg.sub_concept_ids.should.contain "babee"

    xit "removes deleted ids", ->
      @view.$(".broader.ui-droppable [data-drag-ident=c0ffee]").attr "data-deleted-connection", true
      @view.$(".narrower.ui-droppable [data-drag-ident=deadbeef]").attr "data-deleted-connection", true
      @view.updateConceptConnections @event
      dataArg = @view.model.save.firstCall.args[0]
      dataArg.super_concept_ids.should.not.contain "c0ffee"
      dataArg.sub_concept_ids.should.not.contain "deadbeef"

    it "adds non-deleted ids", ->
      @view.updateConceptConnections @event
      dataArg = @view.model.save.firstCall.args[0]
      dataArg.super_concept_ids.should.contain "c0ffee"
      dataArg.sub_concept_ids.should.contain "deadbeef"

    it "disables all form fields", ->
      @view.updateConceptConnections @event
      @view.$("form").hasClass("disabled").should.be.true
      $(el).hasClass("disabled").should.be.true for el in @view.$(".submit a")
      $(el).should.be.disabled for el in @view.$("input,textarea,button")

    xit "disables droppables", ->
      @view.updateConceptConnections @event
      for el in @view.$('.ui-droppable')
        $(el).droppable("option", "disabled").should.be.true if $(el).data("uiDroppable")

    context "notifications", ->

      beforeEach ->
        @view.$el.html $('
          <form class="active">
            <div class="broader">
              <ul>
                <li><div data-drag-ident="c0ffee1" data-deleted-connection="true">Coffee1</div></li>
                <li><div data-drag-ident="c0ffee2" data-new-connection="true">Coffee2</div></li>
              </ul>
            </div>
            <div class="narrower">
              <ul>
                <li><div data-drag-ident="deadbeef1" data-deleted-connection="true">Meat1</div></li>
                <li><div data-drag-ident="deadbeef2" data-new-connection="true">Meat2</div></li>
              </ul>
            </div>
            <div class="submit">
              <a href="#">submitaction</a>
              <button type="submit">submit</button>
            </div>
          </form>
        ')

      it "notifies about success", ->
        I18n.t.withArgs("notifications.concept.broader_added", count: 1, label: "c0ffee2").returns "one broader added"
        I18n.t.withArgs("notifications.concept.broader_deleted", count: 1, label: "c0ffee1").returns "one broader deleted"
        I18n.t.withArgs("notifications.concept.narrower_added", count: 1, label: "deadbeef2").returns "one narrower added"
        I18n.t.withArgs("notifications.concept.narrower_deleted", count: 1, label: "deadbeef1").returns "one narrower deleted"
        Coreon.Models.Notification.info = sinon.spy()

        @view.updateConceptConnections @event
        @deferred.resolve()

        Coreon.Models.Notification.info.callCount.should.be 4
        #TODO: be more verbose
