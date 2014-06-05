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

    beforeEach ->
      @stub $.fn, 'offset', -> top: 0

    fakeTrigger = -> $ '<a>'

    fakeOpts = (opts = {}) ->
      _(opts).defaults
        trigger: fakeTrigger()
        message: ''
        template: -> ''
        action: ->

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
        template = -> '''
          <div class="shim">
            <div class="dialog">
              <p>Do you want to proceed?</p>
            </div>
          </div>
        '''
        view.confirm fakeOpts template: template
        expect(modal).to.have '.shim .dialog'

    context 'position', ->

      position = null

      beforeEach ->
        position = @spy $.fn, 'position'

      opts = (stub) ->
        stub.firstCall.args[0]

      it 'aligns dialog above trigger', ->
        trigger = fakeTrigger()
        view.confirm fakeOpts(trigger: trigger)
        expect(position).to.have.been.calledOnce
        expect(opts position).to.have.property 'my', 'left bottom'
        expect(opts(position).of[0]).to.equal trigger[0]

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

    context 'cancel', ->

      template = null
      modal = null

      beforeEach ->
        modal = $('<div id="coreon-modal">').appendTo 'body'
        template = -> '''
          <div class="dialog">
            <a class="cancel" href="#">Nope</a>
          </div>
        '''

      cancel = (modal) ->
        modal.find('a.cancel')

      it 'removes markup', ->
        view.confirm fakeOpts template: template
        cancel(modal).click()
        expect(modal).to.be.empty

    context 'confirm', ->

      template = null
      modal = null

      beforeEach ->
        modal = $('<div id="coreon-modal">').appendTo 'body'
        template = -> '''
          <div class="dialog">
            <a class="confirm" href="#">Yes</a>
          </div>
        '''

      confirm = (modal) ->
        modal.find('a.confirm')

      it 'removes markup', ->
        view.confirm fakeOpts template: template
        confirm(modal).click()
        expect(modal).to.be.empty

      it 'triggers action', ->
        action = @spy()
        view.confirm fakeOpts
          template: template
          action: action
        confirm(modal).click()
        expect(action).to.have.been.calledOnce
        expect(action).to.have.been.calledOn view

      it 'calls method with matching name', ->
        view.myMethod = @spy()
        view.confirm fakeOpts
          template: template
          action: 'myMethod'
        confirm(modal).click()
        expect(view.myMethod).to.have.been.calledOnce
        expect(view.myMethod).to.have.been.calledOn view

    context 'container', ->

      container = null

      fakeContainer = -> $ '<div>'

      beforeEach ->
        container = fakeContainer()

      it 'is classified for deletion', ->
        view.confirm fakeOpts container: container
        expect(container).to.have.class 'delete'

      it 'is removed on cancel', ->
        modal = $('<div id="coreon-modal">').appendTo 'body'
        template = -> '''
          <div class="dialog">
            <a class="cancel" href="#">abort</a>
          </div>
        '''
        view.confirm fakeOpts
          template: template
          container: container
        modal.find('a.cancel').click()
        expect(container).to.not.have.class 'delete'
