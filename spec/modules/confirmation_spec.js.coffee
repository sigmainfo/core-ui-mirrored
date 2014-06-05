#= require spec_helper
#= require modules/helpers
#= require modules/confirmation

describe "Coreon.Modules.Confirmation", ->

  before ->
    class Coreon.Views.ViewWithConfirmation extends Backbone.View
      _(@::).extend Coreon.Modules.Confirmation

  after ->
    delete Coreon.Views.ViewWithConfirmation

  view = null

  beforeEach ->
    view = new Coreon.Views.ViewWithConfirmation

  afterEach ->
    $(window).off '.coreonConfirmation'

  describe '#confirm()', ->

    fakeTrigger = -> $ '<a>'

    fakeOpts = (opts = {}) ->
      _(opts).defaults
        trigger: fakeTrigger()
        message: ''
        template: -> ''

    context 'template', ->

      it 'renders template', ->
        template = @spy()
        view.confirm fakeOpts template: template
        expect(template).to.have.been.calledOnce

      it 'falls back to default template', ->
        template = @stub Coreon.Templates, 'modules/confirmation'
        opts = fakeOpts()
        opts.template = null
        view.confirm opts
        expect(template).to.have.been.calledOnce

      it 'passes message to template', ->
        template = @spy()
        view.confirm fakeOpts
          template: template
          message: 'Are you sure?'
        expect(template).to.have.been.calledWith message: 'Are you sure?'

      it 'appends markup to modal layer', ->
        modal = $('<div id="coreon-modal">').appendTo 'body'
        markup = '''
          <div class="shim">
            <div class="dialog">
              <p>Do you want to proceed?</p>
            </div>
          </div>
        '''
        template = -> markup
        view.confirm fakeOpts template: template
        expect(modal).to.have '.shim .dialog'

    context 'position', ->

      position = null

      beforeEach ->
        position = @stub $.fn, 'position'

      opts = (stub) ->
        stub.firstCall.args[0]

      it 'aligns dialog above trigger', ->
        trigger = fakeTrigger()
        view.confirm fakeOpts(trigger: trigger)
        expect(position).to.have.been.calledOnce
        expect(opts position).to.have.property 'my', 'left bottom'
        expect(opts position).to.have.property 'of', trigger

      it 'repositions dialog on resize', ->
        view.confirm fakeOpts()
        position.reset()
        $(window).resize()
        expect(position).to.have.been.calledOnce

      it 'repositions dialog on scroll', ->
        view.confirm fakeOpts()
        position.reset()
        $(window).scroll()
        expect(position).to.have.been.calledOnce

#   view = null
#   trigger = null
#
#   before ->
#     class Coreon.Views.MyView extends Backbone.View
#       Coreon.Modules.include @, Coreon.Modules.Confirmation
#
#   after ->
#     delete Coreon.Views.MyView
#
#   beforeEach ->
#     view = new Coreon.Views.MyView
#     $("#konacha")
#       .append(view.$el)
#       .append '''
#         <div id="coreon-modal"></div>
#         '''
#     view.$el.append '''
#       <div class="concept">
#         <a class="delete" href="javascript:void(0)">Delete concept</a>
#       </div>
#     '''
#     trigger = view.$("a.delete")
#
#   afterEach ->
#     $(window).off ".coreonConfirm"
#
#   describe "confirm()", ->
#
#     it "renders confirmation dialog", ->
#       I18n.t.withArgs("confirm.ok").returns "OK"
#       view.confirm
#         trigger: trigger
#         container: view.$ ".concept"
#         message: "Are you sure?"
#         action: ->
#       $("#coreon-modal").should.have ".modal-shim .confirm"
#       $("#coreon-modal .confirm .message").should.have.text "Are you sure?"
#       $("#coreon-modal .confirm .ok").should.have.text "OK"
#
#     it "marks container for deletetion", ->
#       view.confirm
#         trigger: trigger
#         container: view.$('.concept')[0]
#         message: "Are you sure?"
#         action: ->
#       view.$(".concept").should.have.class "delete"
#
#     it "does not require container option", ->
#       confirm = =>
#         view.confirm
#           trigger: trigger
#           container: null
#           message: "Are you sure?"
#           action: ->
#       confirm.should.not.throw Error
#
#     context "cancel", ->
#
#       context "with container", ->
#
#         beforeEach ->
#           view.confirm
#             trigger: trigger
#             container: view.$ ".concept"
#             message: "Are you sure?"
#             action: ->
#
#         it "removes dialog", ->
#           $(".modal-shim").click()
#           $("#coreon-modal").should.be.empty
#
#         it "unmarks container for deletion", ->
#           $(".modal-shim").click()
#           view.$(".concept").should.not.have.class "delete"
#
#
#         it "cancels on escape key", ->
#           keypress= $.Event "keydown"
#           keypress.keyCode = 27
#           $(document).trigger keypress
#           $("#coreon-modal").should.be.empty
#           view.$(".concept").should.not.have.class "delete"
#
#       context "without container", ->
#
#         beforeEach ->
#           view.confirm
#             trigger: trigger
#             container: null
#             message: "Are you sure?"
#             action: ->
#
#         it "does not throw an error", ->
#           cancel = ->
#             $(".modal-shim").click()
#           cancel.should.not.throw Error
#
#     context "action", ->
#
#       action = null
#
#       beforeEach ->
#         action = @spy()
#         view.confirm
#           trigger: trigger
#           container: view.$ ".concept"
#           message: "Are you sure?"
#           action: action
#
#       it "stops propagation", ->
#         event = $.Event "click"
#         event.stopPropagation = @spy()
#         $(".confirm").trigger event
#         event.stopPropagation.should.have.been.calledOnce
#
#       it "removes dialog", ->
#         $(".confirm").click()
#         $("#coreon-modal").should.be.empty
#
#       it "calls action", ->
#         $(".confirm").click()
#         action.should.have.been.calledOnce
#
#       it "calls action on return key", ->
#         keypress= $.Event "keydown"
#         keypress.keyCode = 13
#         $(document).trigger keypress
#         $("#coreon-modal").should.be.empty
#         action.should.have.been.calledOnce
#
#     context 'method as action', ->
#
#       opts = null
#
#       beforeEach ->
#         view.nowDoIt = @spy()
#
#       fakeOpts = (opts) ->
#         _(opts).defaults
#           trigger: trigger
#           message: "Are you sure?"
#           action: ''
#
#       it 'calls method on view when passed in as a string', ->
#         method = @spy()
#         view.doItNow = method
#         view.confirm fakeOpts(action: 'doItNow')
#         $(".confirm").click()
#         expect(method).to.have.been.calledOnce
#         expect(method).to.have.been.calledOn view
