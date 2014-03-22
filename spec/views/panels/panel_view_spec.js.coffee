#= require spec_helper
#= require views/panels/panel_view

describe 'Coreon.Views.Panels.PanelView', ->

  view = null

  beforeEach ->
    view = new Coreon.Views.Panels.PanelView

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'applies class name', ->
    el = view.$el
    expect(el).to.have.class 'panel'

  describe '#widgetize()', ->

    beforeEach ->
      sinon.stub Coreon.Helpers, 'action_for'

    afterEach ->
      Coreon.Helpers.action_for.restore()

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

  describe '#maximize()', ->

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
