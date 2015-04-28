#= require spec_helper
#= require views/panels/terms/edit_term_view

describe 'Coreon.Views.Panels.Terms.EditTermView', ->

  view = null
  model = null
  propertiesStub = null
  propertiesView = null
  serializedProperties = []
  listenToStub = null

  beforeEach ->
    Coreon.Models.RepositorySettings = sinon.stub
    Coreon.Models.RepositorySettings.optionalPropertiesFor = ->
    Coreon.application = sinon.stub
    Coreon.application.langs = ->
      ['en', 'de', 'fr']
    propertiesView = new Backbone.View
    propertiesView =
      isValid: -> true
      render: ->
        $el: $ ''
      serializeArray: -> serializedProperties
      serializeAssetsArray: ->
      countDeleted: -> 0
    propertiesStub = sinon.stub Coreon.Views.Properties, 'EditPropertiesView', -> propertiesView
    model = new Backbone.Model
    model.info = ->
    model.propertiesWithDefaults = ->
    model.errors = ->
    concept = new Backbone.Model
    concept_terms = new Backbone.Collection
    sinon.stub concept_terms, 'add'
    concept.terms = ->
      concept_terms
    view = new Coreon.Views.Panels.Terms.EditTermView model: model, isEdit: true, concept: concept
    listenToStub = sinon.stub(view, 'listenTo').withArgs(propertiesView, 'updateValid')

  afterEach ->
    Coreon.Views.Properties.EditPropertiesView.restore()

  it 'is a backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'has a container', ->
    el = view.$el
    expect(el).to.match 'div'

  describe '#render()', ->

    it 'renders a form', ->
      sinon.spy Coreon.Helpers, 'form_for'
      el = view.render().$else
      expect(Coreon.Helpers.form_for).to.have.been.calledOnce

    it 'renders a hidden input for the term id', ->
      model.id = '1'
      view.render()
      input = view.$('input[type=hidden][name=id]')
      expect(input).to.have.attr 'value', '1'

    it 'renders an input for the term value', ->
      model.set 'value', 'car'
      view.render()
      input = view.$('input[type=text][name="term[value]"]')
      expect(input).to.have.attr 'value', 'car'

    it 'renders an input for the lang value', ->
      model.set 'lang', 'en'
      view.render()
      input = view.$('select[name="term[lang]"]')
      expect(input).to.have.value 'en'

    it 'renders editable properties', ->
      sinon.spy propertiesView, 'render'
      view.render()
      expect(Coreon.Views.Properties.EditPropertiesView).to.have.been.calledOnce
      expect(propertiesView.render).to.have.been.calledOnce

    it 'validates enclosing form when properties change', ->
      view.render()
      expect(listenToStub).to.have.been.calledOnce

    it 'validates enclosing form when properties change', ->
      sinon.stub view, 'validateForm'
      view.render()
      expect(view.validateForm).to.have.been.calledOnce


  describe '#serializeArray()', ->

    it 'returns a structure ready for serialization', ->
      serializedProperties.push {key: 'public', value: true}
      view.render()
      view.$el = $ '''
        <form>
          <input type="hidden" name="id" value="123"/>
          <input type="text" name="term[value]" value="car"/>
          <select name="term[lang]">
            <option value="de" selected>German</option>
            <option value="en">English</option>
          </select>
        </form>
      '''
      array = view.serializeArray()
      expect(array).to.have.property 'id', '123'
      expect(array).to.have.property 'value', 'car'
      expect(array).to.have.property 'lang', 'de'
      expect(array).to.have.property 'properties', serializedProperties

  describe '#isValid()', ->

    it 'returns true if all properties are valid', ->
      view.render()
      propertiesView.isValid = -> true
      expect(view.isValid()).to.be.true

    it 'returns false if one property is invalid', ->
      view.render()
      propertiesView.isValid = -> false
      expect(view.isValid()).to.be.false

  describe '#validateForm()', ->

    it 'disables/enables the submit button if term data are invalid/valid', ->
      view.render()
      view.$el = $ '''
        <div>
          <form>
            <div class="submit">
              <button type="submit"></submit>
            </div>
          </form>
        </div>
      '''
      propertiesView.isValid = -> false
      view.validateForm()
      expect(view.$el.find('form .submit button[type=submit]').prop('disabled')).to.be.true
      propertiesView.isValid = -> true
      view.validateForm()
      expect(view.$el.find('form .submit button[type=submit]').prop('disabled')).to.be.false


  describe '#updateTerm()', ->

    formData = null
    event = null
    saveStub = null
    confirmStub = null

    beforeEach ->
      formData = [
        id: 123,
        value: 'car',
        lang: 'en',
        properties: [
          {key: 'public', value: true}
        ]
      ]
      event = $.Event 'submit'
      sinon.stub view, 'serializeArray', -> formData
      saveStub = sinon.stub(view, 'saveTerm').withArgs(formData)
      confirmStub = sinon.stub(view, 'confirm')

    afterEach =>
      view.serializeArray.restore()
      view.saveTerm.restore()
      view.confirm.restore()

    context 'no deleted properties', ->

      it 'saves the term model', ->
        event.target = '''
          <form>
            <input type="submit">
          </form>
        '''
        view.render()
        view.updateTerm(event)
        expect(saveStub).to.have.been.calledOnce

    context 'with deleted properties', ->

      it 'waits for user confirmation', ->
        propertiesView.countDeleted = -> 1
        event.target = '''
          <form>
            <input type="submit">
            <div class="property delete"
          </form>
        '''
        view.render()
        view.updateTerm(event)
        expect(confirmStub).to.have.been.calledOnce

  describe '#createTerm()', ->

    request = null
    saveAssetsRequest = null
    fetchRequest = null
    formData = null
    saveStub = null
    noteStub = null
    renderStub = null
    triggerStub = null

    beforeEach ->
      request = $.Deferred()
      saveAssetsRequest = $.Deferred()
      formData = [
        value: 'car',
        lang: 'en',
        properties: [
          {key: 'public', value: true}
        ]
      ]
      sinon.stub view, 'serializeArray', -> formData
      view.saveAssets = ->
        saveAssetsRequest = $.Deferred()
      sinon.stub Coreon.Models, 'Term', ->
        term = new Backbone.Model
        saveStub = sinon.stub(term, 'save').withArgs(
          null,
          wait: yes,
        ).returns request
        sinon.stub term, 'fetch', (options) ->
          fetchRequest = $.Deferred()
          fetchRequest.done(options.success) if options.success
          fetchRequest.success = fetchRequest.done
          fetchRequest
        term
      renderStub = sinon.stub view, 'render'
      sinon.stub I18n, 't'
      Coreon.Models.Notification =
        info: ->
      noteStub = sinon.stub Coreon.Models.Notification, 'info'
      triggerStub = sinon.stub(view, 'trigger').withArgs 'created'
      view.editProperties =
        serializeAssetsArray: ->
      view.createTerm()

    afterEach ->
      view.model.save.restore()
      view.render.restore()
      view.trigger.restore()
      Coreon.Models.Notification.info.restore()
      Coreon.Models.Term.restore()
      I18n.t.restore()

    it 'attempts to save the model', ->
      request.resolve()
      saveAssetsRequest.resolve()
      expect(saveStub).to.have.been.calledOnce

    it 're-renders on failure', ->
      request.reject()
      expect(renderStub).to.have.been.calledOnce

    it 'add new term to concept and triggers created event', ->
      request.resolve()
      saveAssetsRequest.resolve()
      fetchRequest.resolve()
      expect(view.concept.terms().add).to.have.been.calledOnce
      expect(triggerStub).to.have.been.calledOnce

  describe '#saveTerm()', ->

    request = null
    fetchRequest = null
    saveAssetsRequest = null
    saveStub = null
    noteStub = null
    setStub = null
    renderStub = null

    beforeEach ->
      request = $.Deferred()
      attrs = [
        {some: 'attrs'}
      ]
      saveStub = sinon.stub(view.model, 'save').withArgs(
        attrs,
        silent: yes,
        wait: yes,
        attrs:
          term: attrs
      ).returns request
      setStub = sinon.stub view.model, 'set'
      renderStub = sinon.stub view, 'render'
      sinon.stub I18n, 't'
      Coreon.Models.Notification =
        info: ->
      sinon.stub view.model, 'fetch', (options) ->
        fetchRequest = $.Deferred()
        fetchRequest.done(options.success) if options.success
        fetchRequest.success = fetchRequest.done
        fetchRequest
      noteStub = sinon.stub Coreon.Models.Notification, 'info'
      view.saveAssets = ->
        saveAssetsRequest = $.Deferred()
      view.editProperties =
        serializeAssetsArray: ->
      view.saveTerm(attrs)


    afterEach ->
      view.model.save.restore()
      view.render.restore()
      view.model.set.restore()
      Coreon.Models.Notification.info.restore()
      I18n.t.restore()

    it 'attempts to save the model', ->
      request.resolve()
      expect(saveStub).to.have.been.calledOnce

    it 'resets the term and re-renders on failure', ->
      request.reject()
      expect(setStub).to.have.been.calledOnce
      expect(renderStub).to.have.been.calledOnce

    it 'notifies the user on success', ->
      request.resolve()
      saveAssetsRequest.resolve()
      fetchRequest.resolve()
      expect(noteStub).to.have.been.calledOnce

