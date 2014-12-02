#= require spec_helper
#= require views/panels/terms/edit_term_view

describe 'Coreon.Views.Panels.Terms.EditTermView', ->

  view = null
  model = null
  propertiesStub = null
  propertiesView = null
  serializedProperties = []

  beforeEach ->
    Coreon.Models.RepositorySettings = sinon.stub
    Coreon.Models.RepositorySettings.optionalPropertiesFor = ->
    propertiesView = new Backbone.View
    propertiesView.serializeArray = ->
    propertiesView =
      isValid: -> true
      render: ->
        $el: $ ''
      serializeArray: -> serializedProperties
    propertiesStub = sinon.stub Coreon.Views.Properties, 'EditPropertiesView', -> propertiesView
    model = new Backbone.Model
    model.info = ->
    model.propertiesWithDefaults = ->
    view = new Coreon.Views.Panels.Terms.EditTermView model: model, isEdit: true
    sinon.stub(view, 'listenTo').withArgs(propertiesView, 'updateValid')

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
      input = view.$('input[type=text][name="term[lang]"]')
      expect(input).to.have.attr 'value', 'en'

    it 'renders editable properties', ->
      sinon.spy propertiesView, 'render'
      view.render()
      expect(Coreon.Views.Properties.EditPropertiesView).to.have.been.calledOnce
      expect(propertiesView.render).to.have.been.calledOnce

  describe '#serializeArray()', ->

    it 'returns a structure ready for serialization', ->
      serializedProperties.push {key: 'public', value: true}
      view.render()
      view.$el = $ '''
        <form>
          <input type="hidden" name="id" value="123"/>
          <input type="text" name="term[value]" value="car"/>
          <input type="text" name="term[lang]" value="de"/>
        </form>
      '''
      array = view.serializeArray()
      expect(array).to.have.property 'id', '123'
      expect(array).to.have.property 'value', 'car'
      expect(array).to.have.property 'lang', 'de'
      expect(array).to.have.property 'properties', serializedProperties

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
        view.updateTerm(event)
        expect(saveStub).to.have.been.calledOnce

    context 'with deleted properties', ->

      it 'waits for user confirmation', ->
        event.target = '''
          <form>
            <input type="submit">
            <div class="property delete"
          </form>
        '''
        view.updateTerm(event)
        expect(confirmStub).to.have.been.calledOnce

  describe '#saveTerm()', ->

    request = null
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
        wait: yes,
        attrs:
          term: attrs
      ).returns request
      setStub = sinon.stub view.model, 'set'
      renderStub = sinon.stub view, 'render'
      sinon.stub I18n, 't'
      Coreon.Models.Notification =
        info: ->
      noteStub = sinon.stub Coreon.Models.Notification, 'info'
      view.saveTerm(attrs)

    afterEach ->
      view.model.save.restore()
      view.render.restore()
      Coreon.Models.Notification.info.restore()
      I18n.t.restore()

    it 'attempts to save the model', ->
      request.resolve()
      expect(saveStub).to.have.been.calledOnce

    it 'notifies the user on failure', ->
      request.resolve()
      expect(noteStub).to.have.been.calledOnce

    it 'resets the term and re-renders', ->
      request.reject()
      expect(setStub).to.have.been.calledOnce
      expect(renderStub).to.have.been.calledOnce