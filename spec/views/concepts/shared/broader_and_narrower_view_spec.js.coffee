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

    afterEach ->
      $(window).off ".coreonSubmit"
 
    context "outside edit mode", ->

      beforeEach ->
        @view.initialize()
        @view.render()

      it "creates no drop zones", ->
        should.not.exist @view.$(".broader.ui-droppable ul").data("uiDroppable")
        should.not.exist @view.$(".narrower.ui-droppable ul").data("uiDroppable")
        should.not.exist @view.$(".broader.static ul").data("uiDroppable")
        should.not.exist @view.$(".narrower.static ul").data("uiDroppable")

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
        sinon.stub @view, "createConcept", ->
          new Backbone.View model: new Backbone.Model

        @view.model.set "super_concept_ids", ["c0ffee"], silent: true
        @view.model.set "sub_concept_ids", ["deadbeef"], silent: true

        @view.initialize()
        @view.render()
        @view.$(".broader ul").append $("<li>").append @el_broad
        @view.$(".narrower ul").append $("<li>").append @el_narrow
        @view.toggleEditMode()

        @dropFunBroad = @view.$(".broader.ui-droppable ul").data("uiDroppable").options.drop
        @dropFunNarrow = @view.$(".narrower.ui-droppable ul").data("uiDroppable").options.drop


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

      it "makes drop zones available", ->
        should.exist @view.$(".broader.ui-droppable ul").data("uiDroppable")
        should.exist @view.$(".narrower.ui-droppable ul").data("uiDroppable")
        should.not.exist @view.$(".broader.static ul").data("uiDroppable")
        should.not.exist @view.$(".narrower.static ul").data("uiDroppable")

      it "has drop methods", ->
        @dropFunBroad.should.be.a.function
        @dropFunNarrow.should.be.a.function

      it "has acceptance methods", ->
        @view.$(".broader.ui-droppable ul").data("uiDroppable").options.accept.should.be.a.function
        @view.$(".narrower.ui-droppable ul").data("uiDroppable").options.accept.should.be.a.function

        @view.dropItemAcceptance.should.be.a "function"
        @view.dropItemAcceptance.should.be.a "function"

      it "denies existing broader concepts for dropping", ->
        @view.model.acceptsConnection = -> false
        @view.dropItemAcceptance(@el_broad).should.be.false
        @view.dropItemAcceptance(@el_narrow).should.be.false
        @view.dropItemAcceptance(@el_own).should.be.false
        @view.dropItemAcceptance(@el_broad).should.be.false
        @view.dropItemAcceptance(@el_narrow).should.be.false
        @view.dropItemAcceptance(@el_own).should.be.false

      it "temporary connects broader concept", ->
        @dropFunBroad {}, draggable: @el_foreign
        item = @view.$(".broader.ui-droppable ul li [data-drag-ident=bad1dea]")
        should.exist item
        $(item).data("new-connection").should.be.true

      it "temporary connects narrower concept", ->
        @dropFunNarrow {}, draggable: @el_foreign
        item = @view.$(".narrower.ui-droppable ul li [data-drag-ident=bad1dea]")
        should.exist item
        $(item).data("new-connection").should.be.true

      it "accepts non-existing concepts", ->
        @view.model.acceptsConnection = -> true
        @view.dropItemAcceptance(@el_foreign).should.be.true
        @view.dropItemAcceptance(@el_foreign).should.be.true

      it "denies temporary connected broader concepts", ->
        @view.model.acceptsConnection = -> true
        @dropFunBroad {}, draggable: @el_foreign
        @view.dropItemAcceptance(@el_foreign).should.be.false
        @view.dropItemAcceptance(@el_foreign).should.be.false

      it "denies temporary connected narrower concepts", ->
        @view.model.acceptsConnection = -> true
        @dropFunNarrow {}, draggable: @el_foreign
        @view.dropItemAcceptance(@el_foreign).should.be.false
        @view.dropItemAcceptance(@el_foreign).should.be.false

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

    it "marks deleted list items", ->
      @view.onDisconnect(@el_broad)
      #@view.$(".broader [data-drag-ident=c0ffee]").data("deleted-connection").should.be.true
      @el_broad.data("deleted-connection").should.be.true
      @view.onDisconnect(@el_narrow)
      #@view.$(".narrower [data-drag-ident=deadbeef]").data("deleted-connection").should.be.true
      @el_narrow.data("deleted-connection").should.be.true

    it "doesn't mark non-deleted list items in broader list", ->
      @view.onDisconnect(@el_narrow)
      should.not.exist @view.$(".broader [data-drag-ident=c0ffee]").data("deleted-connection")

    it "doesn't mark non-deleted list items in narrower list", ->
      @view.onDisconnect(@el_broad)
      should.exist @view.$(".narrower [data-drag-ident=deadbeef]")

    it "accepts reconnection of marked items", ->
      @view.model.acceptsConnection = -> false
      @view.onDisconnect(@el_narrow)
      @view.onDisconnect(@el_broad)
      @view.dropItemAcceptance(@el_broad).should.be.true
      @view.dropItemAcceptance(@el_narrow).should.be.true

    it "unmarks reconnected items on reconnect", ->
      @view.onDisconnect(@el_narrow)
      @view.onDisconnect(@el_broad)
      @view.onDrop("narrower", @el_narrow)
      @view.onDrop("broader", @el_broad)
      $(el).data("deleted-connection").should.be.false for el in @view.$(".list [data-deleted-connection]")


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

    afterEach ->
      @view.model.save.restore()

    it "is triggered on submit", ->
      @view.updateConceptConnections = sinon.spy()
      @view.delegateEvents()
      @view.$("form.active").submit()
      @view.updateConceptConnections.should.have.been.calledOnce

    it "adds new ids", ->
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

    it "removes deleted ids", ->
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
            <div class="broader static">
              <ul>
                <li><div data-drag-ident="c0ffee1">Coffee1</div></li>
              </ul>
            </div>
            <div class="broader ui-droppable">
              <ul>
                <li><div data-drag-ident="c0ffee1" data-deleted-connection="true">Coffee1</div></li>
                <li><div data-drag-ident="c0ffee2" data-new-connection="true">Coffee2</div></li>
              </ul>
            </div>
            <div class="narrower static">
              <ul>
                <li><div data-drag-ident="deadbeef1">Meat1</div></li>
              </ul>
            </div>
            <div class="narrower ui-droppable">
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
        I18n.t.withArgs("notifications.concept.broader_added", n:1).returns "one broader added"
        I18n.t.withArgs("notifications.concept.broader_deleted", n:1).returns "one broader deleted"
        I18n.t.withArgs("notifications.concept.narrower_added", n:1).returns "one narrower added"
        I18n.t.withArgs("notifications.concept.narrower_deleted", n:1).returns "one narrower deleted"
        Coreon.Models.Notification.info = sinon.spy()

        @view.updateConceptConnections @event
        @view.model.save.firstCall.args[1].success()

        Coreon.Models.Notification.info.callCount.should.be 4
        Coreon.Models.Notification.info.should.have.been.calledWith "one broader added"
        Coreon.Models.Notification.info.should.have.been.calledWith "one broader deleted"
        Coreon.Models.Notification.info.should.have.been.calledWith "one narrower added"
        Coreon.Models.Notification.info.should.have.been.calledWith "one narrower deleted"

