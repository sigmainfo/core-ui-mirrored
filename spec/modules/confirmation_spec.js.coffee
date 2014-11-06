#= require spec_helper
#= require modules/helpers
#= require modules/confirmation

describe "Coreon.Modules.Confirmation", ->

  before ->
    class Coreon.Views.MyView extends Backbone.View
      Coreon.Modules.include @, Coreon.Modules.Confirmation

  after ->
    delete Coreon.Views.MyView

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.MyView
    $("#konacha")
      .append(@view.$el)
      .append '''
        <div id="coreon-modal"></div>
        '''
    @view.$el.append '''
      <div class="concept">
        <a class="delete" href="javascript:void(0)">Delete concept</a>
      </div>
    '''
    @trigger = @view.$("a.delete")

  afterEach ->
    I18n.t.restore()
    $(window).off ".coreonConfirm"

  describe "confirm()", ->

    it "renders confirmation dialog", ->
      I18n.t.withArgs("confirm.ok").returns "OK"
      @view.confirm
        trigger: @trigger
        container: @view.$ ".concept"
        message: "Are you sure?"
        action: ->
      $("#coreon-modal").should.have ".modal-shim .confirm"
      $("#coreon-modal .confirm .message").should.have.text "Are you sure?"
      $("#coreon-modal .confirm .ok").should.have.text "OK"

    it "marks container for deletion", ->
      @view.confirm
        trigger: @trigger
        container: @view.$ ".concept"
        message: "Are you sure?"
        action: ->
      @view.$(".concept").should.have.class "delete"

    it "does not require container option", ->
      confirm = =>
        @view.confirm
          trigger: @trigger
          container: null
          message: "Are you sure?"
          action: ->
      confirm.should.not.throw Error


    context "cancel", ->

      context "with container", ->

        testRestore = null

        beforeEach ->
          testRestore = sinon.spy()
          @view.confirm
            trigger: @trigger
            container: @view.$ ".concept"
            message: "Are you sure?"
            action: ->
            restore: testRestore

        it "removes dialog", ->
          $(".modal-shim").click()
          $("#coreon-modal").should.be.empty

        it "unmarks container for deletion", ->
          $(".modal-shim").click()
          @view.$(".concept").should.not.have.class "delete"

        it "cleanups with a restore callback", ->
          $(".modal-shim").click()
          expect(testRestore).to.have.been.calledOnce

        it "cancels on escape key", ->
          keypress= $.Event "keydown"
          keypress.keyCode = 27
          $(document).trigger keypress
          $("#coreon-modal").should.be.empty
          @view.$(".concept").should.not.have.class "delete"

      context "without container", ->

        beforeEach ->
          @view.confirm
            trigger: @trigger
            container: null
            message: "Are you sure?"
            action: ->

        it "does not throw an error", ->
          cancel = ->
            $(".modal-shim").click()
          cancel.should.not.throw Error

    context "destroy", ->

      beforeEach ->
        @action = sinon.spy()
        @view.confirm
          trigger: @trigger
          container: @view.$ ".concept"
          message: "Are you sure?"
          action: @action

      it "stops propagation", ->
        event = $.Event "click"
        event.stopPropagation = sinon.spy()
        $(".confirm").trigger event
        event.stopPropagation.should.have.been.calledOnce

      it "removes dialog", ->
        $(".confirm").click()
        $("#coreon-modal").should.be.empty

      it "calls action", ->
        $(".confirm").click()
        @action.should.have.been.calledOnce

      it "destroys on return key", ->
        keypress= $.Event "keydown"
        keypress.keyCode = 13
        $(document).trigger keypress
        $("#coreon-modal").should.be.empty
        @action.should.have.been.calledOnce
