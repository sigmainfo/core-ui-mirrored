#= require spec_helper
#= require views/panels/panel_view

describe 'Coreon.Views.Panels.PanelView', ->

  model = null
  view = null

  beforeEach ->
    model = new Backbone.Model
    view = new Coreon.Views.Panels.PanelView
      panel: model

  afterEach ->
    view.remove()

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'applies class name', ->
    el = view.$el
    expect(el).to.have.class 'panel'

  describe '#initialize()', ->

    it 'assigns panel model', ->
      assigned = view.panel
      expect(assigned).to.equal model

  describe '#widgetize()', ->

    beforeEach ->
      sinon.stub Coreon.Helpers, 'action_for'
      model.set 'widget', on

    afterEach ->
      Coreon.Helpers.action_for.restore()

    context 'triggers', ->

      it 'is triggered when changed to widget mode', ->
        widgetize = sinon.spy()
        view.widgetize = widgetize
        model.trigger 'change:widget', model, on
        expect(widgetize).to.have.been.calledOnce
        expect(widgetize).to.have.been.calledOn view

      it 'is not triggered when changed to maximized mode', ->
        widgetize = sinon.spy()
        view.widgetize = widgetize
        model.trigger 'change:widget', model, off
        expect(widgetize).to.not.have.been.called

    it 'can be chained', ->
      result = view.widgetize()
      expect(result).to.equal view

    it 'adds class to el', ->
      view.widgetize()
      el = view.$el
      expect(el).to.have.class 'widget'

    it 'appends maximize action to titlebar', ->
      action_for = Coreon.Helpers.action_for
      action_for
        .withArgs('panel.maximize')
        .returns '<a class="maximize">Max</a>'
      view.$el.html '''
        <div class="titlebar">
          <div class="actions">
          </div>
        </div>
      '''
      view.widgetize()
      action = view.$('.actions a.maximize')
      expect(action).to.exist

    it 'appends maximize action only once', ->
      action_for = Coreon.Helpers.action_for
      action_for
        .withArgs('panel.maximize')
        .returns '<a class="maximize">Max</a>'
      view.$el.html '''
        <div class="titlebar">
          <div class="actions">
            <a class="maximize">Max</a>
          </div>
        </div>
      '''
      view.widgetize()
      action = view.$('.actions a.maximize')
      expect(action).to.have.lengthOf 1

    it 'resizes el', ->
      model.set
        width: 300
        height: 120
      , silent: yes
      view.widgetize()
      style = view.$el.attr 'style'
      expect(style).to.include 'width: 300px'
      expect(style).to.include 'height: 120px'

    context 'resizable', ->

      it 'enables resizable functionality', ->
        view.widgetize()
        resizable = not view.$el.resizable('option', 'disabled')
        expect(resizable).to.be.true

      it 'allows resizing on left and bottom edges', ->
        view.widgetize()
        handles = view.$el.resizable('option', 'handles')
          .split(/\s*,\s*/)
          .sort()
        expect(handles).to.eql ['s', 'sw', 'w']

      it 'constrains resizing', ->
        view.widgetize()
        resizable = view.$el.resizable('option')
        expect(resizable).to.have.property 'minWidth', 240
        expect(resizable).to.have.property 'minHeight', 80

  describe '#maximize()', ->

    beforeEach ->
      model.set 'widget', off

    context 'triggers', ->

      it 'is triggered when changed to maximized mode', ->
        maximize = sinon.spy()
        view.maximize = maximize
        model.trigger 'change:widget', model, off
        expect(maximize).to.have.been.calledOnce
        expect(maximize).to.have.been.calledOn view

      it 'is not triggered when changed to widget mode', ->
        maximize = sinon.spy()
        view.maximize = maximize
        model.trigger 'change:widget', model, on
        expect(maximize).to.not.have.been.called

    it 'can be chained', ->
      result = view.maximize()
      expect(result).to.equal view

    it 'removes class from el', ->
      view.$el.addClass 'widget'
      view.maximize()
      el = view.$el
      expect(el).to.not.have.class 'widget'

    it 'removes maximize button', ->
      view.$el.html '''
        <div class="titlebar">
          <div class="actions">
            <a class="maximize">Max</a>
          </div>
        </div>
      '''
      view.maximize()
      action = view.$('.actions a.maximize')
      expect(action).to.not.exist

    it 'enables autolayout of el', ->
      view.$el.width 300
      view.$el.height 120
      view.maximize()
      el = view.$el
      expect(el).to.not.have.attr 'style'

    it 'removes resizable functionality', ->
      view.$el.addClass 'ui-resizable'
      resizable = sinon.spy()
      view.$el.resizable = resizable
      view.maximize()
      expect(resizable).to.have.been.calledOnce
      expect(resizable).to.have.been.calledWith 'destroy'

  describe '#resize()', ->

    context 'triggers', ->

      resize = null

      beforeEach ->
        resize = sinon.spy()
        view.resize = resize
        view.initialize panel: model

      it 'is triggered by change of width', ->
        model.trigger 'change:width'
        expect(resize).to.have.been.calledOnce
        expect(resize).to.have.been.calledOn view

      it 'is triggered by change of height', ->
        model.trigger 'change:height'
        expect(resize).to.have.been.calledOnce
        expect(resize).to.have.been.calledOn view

      it 'is triggerd on window resize', ->
        $(window).trigger 'resize'
        expect(resize).to.have.been.calledOnce
        expect(resize).to.have.been.calledOn view

    context 'widget', ->

      beforeEach ->
        model.set 'widget', on, silent: yes

      it 'resizes el', ->
        model.set
         width: 500
         height: 345
        , silent: yes
        view.resize()
        style = view.$el.attr 'style'
        expect(style).to.include 'width: 500px'
        expect(style).to.include 'height: 345px'

      it 'keeps el aligned to left of widgets column', ->
        view.$el.css left: 23
        view.resize()
        style = view.$el.attr 'style'
        expect(style).to.include 'left: 0px'

    context 'maximized', ->

      beforeEach ->
        model.set 'widget', off, silent: yes

      it 'enables auto layout for el', ->
        model.set
         width: 500
         height: 345
        , silent: yes
        view.resize()
        el = view.$el
        expect(el).to.not.have.attr 'style'

  describe '#updateSizes()', ->

    it 'is called by #resize()', ->
      $('#konacha').append view.$el
      update = sinon.spy()
      view.updateSizes = update
      model.set
        widget: on
        width: 345
      , silent: yes
      view.resize()
      expect(update).to.have.been.calledOnce
      expect(update).to.have.been.calledWith 345

    it 'adds classes that are within range', ->
      view.sizes =
        mini: [0, 150]
        medi: [100, 550]
        maxi: [500, 950]
      view.updateSizes 220
      el = view.$el
      expect(el).to.not.have.class 'mini'
      expect(el).to.have.class 'medi'
      expect(el).to.not.have.class 'maxi'

    it 'removes classes that are outside range', ->
      view.sizes =
        mini: [0, 150]
        medi: [100, 550]
        maxi: [500, 950]
      el = view.$el
      el.addClass 'mini'
      el.addClass 'maxi'
      view.updateSizes 220
      expect(el).to.not.have.class 'mini'
      expect(el).to.have.class 'medi'
      expect(el).to.not.have.class 'maxi'

    it 'allows ranges with lower boundary only', ->
      view.sizes =
        medi: [100]
        maxi: [500]
      view.updateSizes 220
      el = view.$el
      expect(el).to.have.class 'medi'
      expect(el).to.not.have.class 'maxi'

  describe '#resizeStart()', ->

    beforeEach ->
      view.widgetize()

    it 'is called by resizable', ->
      start = sinon.spy()
      view.resizeStart = start
      trigger = view.$el.resizable('option', 'start')
      event = $.Event 'drag'
      ui = size:
        width: 200
        height: 120
      trigger event, ui
      expect(start).to.have.been.calledOnce
      expect(start).to.have.been.calledOn view
      expect(start).to.have.been.calledWith ui

  describe '#resizeStep()', ->

    beforeEach ->
      view.widgetize()

    it 'is called by resizable', ->
      step = sinon.spy()
      view.resizeStep = step
      trigger = view.$el.resizable('option', 'resize')
      event = $.Event 'drag'
      ui = size:
        width: 200
        height: 120
      trigger event, ui
      expect(step).to.have.been.calledOnce
      expect(step).to.have.been.calledOn view
      expect(step).to.have.been.calledWith ui

    it 'keeps panel dimensions in sync', ->
      ui = size:
        width: 200
        height: 120
      view.resizeStep ui
      width = model.get('width')
      expect(width).to.equal 200
      height = model.get('height')
      expect(height).to.equal 120

  describe '#resizeStop()', ->

    beforeEach ->
      view.widgetize()

    it 'is called by resizable', ->
      stop = sinon.spy()
      view.resizeStop = stop
      trigger = view.$el.resizable('option', 'stop')
      event = $.Event 'drag'
      ui = size:
        width: 200
        height: 120
      trigger event, ui
      expect(stop).to.have.been.calledOnce
      expect(stop).to.have.been.calledOn view
      expect(stop).to.have.been.calledWith ui

  describe '#switchToMax()', ->

    event = null
    action = null

    beforeEach ->
      view.$el.html '''
        <div class="actions">
          <a class="maximize" href="javascript:void(0)">Maximize</a>
        </div>
      '''
      action = view.$('.actions .maximize')
      event = $.Event 'click'
      event.target = action[0]

    it 'is triggered by click on action', ->
      switchToMax = sinon.spy()
      view.switchToMax = switchToMax
      view.delegateEvents()
      action.trigger event
      expect(switchToMax).to.have.been.calledOnce
      expect(switchToMax).to.have.been.calledOn view
      expect(switchToMax).to.have.been.calledWith event

    it 'switches widget mode on model', ->
      model.set 'widget', on, silent: yes
      view.switchToMax event
      widgetized = model.get('widget')
      expect(widgetized).to.be.false

    it 'prevents default action', ->
      preventDefault = sinon.spy()
      event.preventDefault = preventDefault
      view.switchToMax event
      expect(preventDefault).to.have.been.calledOnce
