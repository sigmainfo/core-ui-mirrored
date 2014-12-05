#= require spec_helper
#= require views/panels/concepts/concept_view

describe 'Coreon.Views.Panels.Concepts.ConceptView', ->

  beforeEach ->
    Coreon.application = new Backbone.Model
    Coreon.application.repositorySettings = ->
    Coreon.application.langs = -> []
    Coreon.Models.RepositorySettings.languageOptions = -> []
    Coreon.application.sourceLang = -> 'none'
    Coreon.application.targetLang = -> 'none'
    sinon.stub(Coreon.Models.RepositorySettings, 'propertiesFor').returns []
    sinon.stub(Coreon.Models.RepositorySettings, 'optionalPropertiesFor').returns []
    sinon.stub I18n, 't'
    @broaderAndNarrower = new Backbone.View
    sinon.stub Coreon.Views.Concepts.Shared, 'BroaderAndNarrowerView', => @broaderAndNarrower

    @property = new Backbone.Model

    property = {lang: 'en', value: 'test', errors: {}}
    property.info = -> {}
    property_group = {key: 'label', type: 'text', properties: [property]}


    @concept = new Backbone.Model
    @concept.info = -> {}
    @concept.revert = ->
    @concept.set 'properties', [ @property ], silent: true
    @concept.termsByLang = -> {}
    terms = new Backbone.Collection
    @concept.terms = -> terms
    @concept.propertiesWithDefaults = -> [ property_group ]

    @view = new Coreon.Views.Panels.Concepts.ConceptView
      model: @concept
    sinon.stub Coreon.Helpers, 'can'
    Coreon.Helpers.can.returns true

  afterEach ->
    I18n.t.restore()
    Coreon.Views.Concepts.Shared.BroaderAndNarrowerView.restore()
    Coreon.application = null
    Coreon.Helpers.can.restore()
    Coreon.Models.RepositorySettings.propertiesFor.restore()
    Coreon.Models.RepositorySettings.optionalPropertiesFor.restore()

  it 'is a Backbone view', ->
    expect( @view ).to.be.an.instanceof Backbone.View

  it 'creates container', ->
    expect( @view.$el ).to.match '.concept'

  describe '#render()', ->

    it 'can be chained', ->
      expect( @view.render() ).to.equal @view

    it 'is triggered by model change', ->
      @view.render = sinon.spy()
      @view.initialize()
      @concept.trigger 'change'
      expect( @view.render ).to.have.been.calledOnce

    it 'is triggered by edit mode change', ->
      @view.render = sinon.spy()
      @view.initialize()
      Coreon.application.trigger 'change:editing'
      expect( @view.render ).to.have.been.calledOnce
      expect( @view.render ).to.have.been.calledOn @view

    it 'renders label', ->
      @concept.set 'label', 'Handgun', silent: true
      @view.render()
      expect( @view.$el ).to.have 'h2.label'
      expect( @view.$('h2.label') ).to.have.text 'Handgun'

    it 'renders system info', ->
      I18n.t.withArgs('concept.info.label').returns 'System Info'
      @concept.info = ->
        id: '123'
        legacy_id: '543'
      @view.render()
      expect( @view.$el ).to.have "> .concept-head .actions .system-info-toggle"
      expect( @view.$("> .concept-head .actions .system-info-toggle") ).to.have.text "System Info"
      expect( @view.$el ).to.have "> .concept-head .system-info"
      expect( @view.$("> .concept-head .system-info").css("display") ).to.equal "none"
      expect( @view.$("> .concept-head .system-info th").eq(0) ).to.have.text "id"
      expect( @view.$("> .concept-head .system-info td").eq(0) ).to.have.text "123"
      expect( @view.$("> .concept-head .system-info th").eq(1) ).to.have.text "legacy_id"
      expect( @view.$("> .concept-head .system-info td").eq(1) ).to.have.text "543"

    it 'renders tree', ->
      @broaderAndNarrower.render = sinon.stub().returns @broaderAndNarrower
      @view.render()
      expect( @broaderAndNarrower.render ).to.have.been.calledOnce
      expect( $.contains(@view.el, @broaderAndNarrower.el) ).to.be.true

    context 'edit mode off', ->

      beforeEach ->
        Coreon.application.set 'editing', off, silent: yes

      it 'classifies el', ->
        @view.render()
        expect( @view.$el ).to.have.class 'show'
        expect( @view.$el ).to.not.have.class 'edit'

    context 'edit mode on', ->

      beforeEach ->
        Coreon.application.set 'editing', on, silent: yes

      it 'classifies el', ->
        @view.render()
        expect( @view.$el ).to.have.class 'edit'
        expect( @view.$el ).to.not.have.class 'show'

    context 'with edit privileges', ->

      beforeEach ->
        Coreon.Helpers.can.returns true

      it 'renders delete concept link', ->
        I18n.t.withArgs('concept.delete').returns 'Delete concept'
        @view.render()
        expect( @view.$el ).to.have '.edit a.delete-concept'
        expect( @view.$('a.delete-concept') ).to.have.text 'Delete concept'

      it 'renders edit concept link', ->
        I18n.t.withArgs('concept.edit.label').returns 'Edit concept'
        @view.render()
        expect( @view.$el ).to.have 'a.edit-concept'
        expect( @view.$('a.edit-concept') ).to.have.text 'Edit concept'

    context 'without edit privileges', ->

      beforeEach ->
        Coreon.Helpers.can.returns false

      it 'does not render delete concept link', ->
        @view.render()
        expect( @view.$el ).to.not.have 'a.delete'

      it 'does not render edit concept link', ->
        @view.render()
        expect( @view.$el ).to.not.have 'a.edit-concept'


  describe '#toggleInfo()', ->

    beforeEach ->
      @view.$el.append """
        <section>
          <div class="actions">
            <h3 class="system-info-toggle">INFO</h3>
          </div>
          <div class="system-info">foo</div>
        </section>
      """
      $("#konacha").append @view.$el

    it "is triggered by click on system info toggle", ->
      @view.toggleInfo = sinon.spy()
      @view.delegateEvents()
      @view.$(".system-info-toggle").click()
      expect( @view.toggleInfo ).to.have.been.calledOnce

    it "toggles system info", ->
      @view.toggleInfo()
      expect( @view.$(".system-info") ).to.be.hidden
      @view.toggleInfo()
      expect( @view.$(".system-info") ).to.be.visible

  describe '#selectProperty()', ->

    beforeEach ->
      @view.$el.append '''
        <table class="properties">
          <td>
            <ul class="index">
              <li data-index="0" class="selected">1</li>
              <li data-index="1">2</li>
            </ul>
            <ul class="values">
              <li class="selected">foo</li>
              <li>bar</li>
            </ul>
          </td>
        </table>
        '''
      @tab = @view.$('.index li').eq(1)

      @event = $.Event 'click'
      @event.target = @tab[0]

    it 'is triggered by click on selector', ->
      @view.selectProperty = sinon.stub().returns false
      @view.delegateEvents()
      @tab.trigger @event
      expect( @view.selectProperty ).to.have.been.calledOnce
      expect( @view.selectProperty ).to.have.been.calledWith @event

    it 'updates selection', ->
      @view.selectProperty @event
      expect( @view.$('.index li').eq(1) ).to.have.class 'selected'
      expect( @view.$('.index li').eq(0) ).to.not.have.class 'selected'
      expect( @view.$('.values li').eq(1) ).to.have.class 'selected'
      expect( @view.$('.values li').eq(0) ).to.not.have.class 'selected'

  describe '#toggleEditMode()', ->

    beforeEach ->
      @view.render()
      Coreon.application.set 'editing', off

    it 'is triggered by click on edit mode toggle', ->
      @view.toggleEditMode = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('.edit-concept').click()
      expect( @view.toggleEditMode ).to.have.been.calledOnce

    it 'toggles edit mode value', ->
      @view.$('.edit-concept').click()
      expect( Coreon.application.get 'editing' ).to.be.true
      @view.$('.edit-concept').click()
      expect( Coreon.application.get 'editing' ).to.be.false

  describe '#toggleEditConceptProperties()', ->

    beforeEach ->
      @concept.properties = -> models: []
      @concept.persistedAttributes = -> {}
      Coreon.application.set 'editing', on, silent: yes
      @view.editProperties = no
      @view.render()

    it 'is triggered by click on edit-properties toggle', ->
      @view.toggleEditConceptProperties = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('.edit-properties').click()
      expect( @view.toggleEditConceptProperties ).to.have.been.calledOnce

    it 'toggles edit properties value', ->
      expect( @view.editProperties ).to.be.false
      @view.$('.edit-properties').click()
      expect( @view.editProperties ).to.be.true

    it 'rerenders the view', ->
      @view.render = sinon.spy()
      @view.delegateEvents()
      @view.$('.edit-properties').click()
      expect( @view.render ).to.have.been.calledOnce

    it 'renders properties template in edit mode', ->
      @view.editing = yes
      @view.editProperties = no
      @view.render()
      expect( @view.$el ).to.have('section.properties')
      expect( @view.$el ).to.not.have('section.edit')

    it 'renders properties edit template in edit properties mode', ->
      @view.editing = yes
      @view.editProperties = yes
      @view.render()
      expect( @view.$el ).to.have('section.properties.edit')

  describe '#cancelForm()', ->

    beforeEach ->
      @view.$el.append '''
        <div>
          <form class="term create">
            <div class="submit">
              <a class="cancel" href="javascript:history.back()">Cancel</a>
              <button type="submit">Create term</button>
            </div>
          </form>
          <div class="edit" style="display:none">
            <a class="add-term" ref="javascript:void(0)">Add term</a>
          </div>
        </div>
        '''
      @event = $.Event 'click'
      @trigger = @view.$('form a.cancel')
      @event.target = @trigger[0]

    it 'is triggered by click on cancel link', ->
      @view.cancelForm = sinon.stub().returns false
      @view.delegateEvents()
      @trigger.click()
      expect( @view.cancelForm ).to.have.been.calledOnce

    it 'is not triggered when link is disabled', ->
      @view.cancelForm = sinon.stub().returns false
      @view.delegateEvents()
      @trigger.addClass 'disabled'
      @trigger.click()
      expect( @view.cancelForm ).to.not.have.been.called

    it 'prevents default action', ->
      @event.preventDefault = sinon.spy()
      @view.cancelForm @event
      expect( @event.preventDefault ).to.have.been.calledOnce

    it 'removes wrapping form', ->
      @view.$el.append '''
        <form class="other"></form>
      '''
      @view.cancelForm @event
      expect( @view.$el ).to.not.have 'form.term.create'
      expect( @view.$el ).to.have 'form.other'

    it 'shows related edit actions', ->
      $('#konacha').append @view.$el
      @view.cancelForm @event
      expect( @view.$('.edit a.add-term') ).to.be.visible

  describe '#reset()', ->

    beforeEach ->
      @view.$el.append '''
        <div>
          <form class="term create">
            <div class="submit">
              <a class="reset" href="javascript:void(0)">Reset</a>
              <button type="submit">Create term</button>
            </div>
          </form>
          <div class="edit" style="display:none">
            <a class="add-term" ref="javascript:void(0)">Add term</a>
          </div>
        </div>
        '''
      @event = $.Event 'click'
      @trigger = @view.$('form a.reset')
      @event.target = @trigger[0]

    it 'is triggered by click on reset link', ->
      @view.reset = sinon.stub().returns false
      @view.delegateEvents()
      @trigger.click()
      expect( @view.reset ).to.have.been.calledOnce

    it 'is not triggered when link is disabled', ->
      @view.reset = sinon.stub().returns false
      @view.delegateEvents()
      @trigger.addClass 'disabled'
      @trigger.click()
      expect( @view.reset ).to.not.have.been.called

    it 'prevents default action', ->
      @event.preventDefault = sinon.spy()
      @view.reset @event
      expect( @event.preventDefault ).to.have.been.calledOnce

    it 'rerenders form', ->
      @view.render = sinon.spy()
      @view.reset @event
      expect( @view.render ).to.have.been.calledOnce

    it 'drops remote validation errors', ->
      @view.model.remoteError = "foo: ['must be bar']"
      @view.reset @event
      expect( @view.model ).to.have.property 'remoteError', null

    it 'restores previous state', ->
      @view.model.revert = sinon.stub().returns false
      @view.reset @event
      expect( @view.model.revert ).to.have.been.calledOnce

  describe '#delete()', ->

    beforeEach ->
      $('#konacha')
        .append(@view.$el)
        .append '''
        <div id="coreon-modal"></div>
        '''
      @view.$el.append '''
        <div class="concept">
          <div class="edit">
            <a class="delete-concept" href="javascript:void(0)">Delete concept</a>
          </div>
        </div>
        '''
      @trigger = @view.$('a.delete-concept')
      @event = $.Event 'click'
      @event.target = @trigger[0]
      @view.confirm = sinon.spy()

    it 'is triggered by click on remove concept link', ->
      @view.delete = sinon.stub().returns false
      @view.delegateEvents()
      @view.$('.edit .delete-concept').trigger @event
      expect( @view.delete ).to.have.been.calledOnce

    it 'renders confirmation dialog', ->
      I18n.t.withArgs('concept.confirm_delete').returns 'This concept will be deleted permanently.'
      @view.delete @event
      expect( @view.confirm ).to.have.been.calledOnce
      options = @view.confirm.firstCall.args[0]
      expect( options ).to.have.property 'message', 'This concept will be deleted permanently.'

    it 'marks concept for deletetion', ->
      @view.delete @event
      options = @view.confirm.firstCall.args[0]
      expect( options.container[0] ).to.equal @view.$('.concept')[0]

    context 'confirm', ->

      fakeHits = (attrs) ->
        new Backbone.Collection attrs

      fakeConcept = -> {}

      beforeEach ->
        Coreon.application = repository: -> id: '8765jhgf'
        sinon.stub Backbone.history, 'navigate'
        @view.delete @event
        @action = @view.confirm.firstCall.args[0].action

      afterEach ->
        Coreon.application = null
        Backbone.history.navigate.restore()

      it 'redirects to repository root when done', ->
        Coreon.application = repository: -> id: '8765jhgf'
        @action()
        expect( Backbone.history.navigate ).to.have.been.calledOnce
        expect( Backbone.history.navigate ).to.have.been.calledWith '/8765jhgf', trigger: true

      it 'clears hits', ->
        hits = fakeHits [result: fakeConcept()]
        try
          sinon.stub Coreon.Collections.Hits, 'collection', -> hits
          @action()
          expect(hits).to.have.property 'length', 0
        finally
          Coreon.Collections.Hits.collection.restore()

      it 'destroys model', ->
        @view.model.destroy = sinon.spy()
        @action()
        expect( @view.model.destroy ).to.have.been.calledOnce

      it 'notifies about destruction', ->
        I18n.t.withArgs('notifications.concept.deleted').returns 'baaam!'
        Coreon.Models.Notification.info = sinon.spy()
        @action()
        expect( Coreon.Models.Notification.info ).to.have.been.calledOnce
        expect( Coreon.Models.Notification.info ).to.have.been.calledWith 'baaam!'

  describe 'clipboard interaction', ->

    beforeEach ->
      @collection = new Backbone.Collection
      sinon.stub Coreon.Collections.Clips, 'collection', => @collection
      sinon.spy @view, 'setClipboardButton'

    afterEach ->
      Coreon.Collections.Clips.collection.restore()
      @view.setClipboardButton.restore()

    it 'sets button if clips changing', ->
      @view.initialize()
      @collection.add @concept
      @collection.reset []
      expect( @view.setClipboardButton ).to.have.been.calledTwice
