#= require spec_helper
#= require views/properties/property_fieldset_view
#= require templates/properties/property_fieldset

describe 'Coreon.Views.Properties.PropertyFieldsetView', ->

  view = null
  el = null
  model = null
  index = 0
  scopePrefix = null
  langs = ['en', 'de', 'fr']

  beforeEach ->
    sinon.stub jQuery.fn, 'coreonSelect'
    sinon.stub jQuery.fn, 'isOnScreen'
    sinon.stub jQuery.fn, 'scrollToReveal'
    sinon.stub I18n, 't'
    Coreon.application = sinon.stub
    Coreon.application.langs = -> langs
    Coreon.Helpers.graphUri = (uri) -> "http://#{uri}"
    Coreon.Modules.Assets =
      assetRepresenter: -> {}

  afterEach ->
    I18n.t.restore()
    jQuery.fn.coreonSelect.restore()
    jQuery.fn.isOnScreen.restore()
    jQuery.fn.scrollToReveal.restore()

  it 'is a Backbone view', ->
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model
    expect(view).to.be.an.instanceof Backbone.View

  it 'has a template', ->
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model
    expect(view).to.have.property 'template'

  it 'accepts extra options', ->
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: 2, scopePrefix: 'concept'
    expect(view).to.have.property 'index', 2
    expect(view).to.have.property 'scopePrefix', 'concept'

  it 'creates a name for the field', ->
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: 2
    expect(view).to.have.property 'name', 'properties[2]'

  it 'creates a name for the field using scopePrefix if given', ->
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: 3, scopePrefix: 'concept'
    expect(view).to.have.property 'name', 'concept[properties][3]'

  it 'gets the language settings from the repo config', ->
    view = new Coreon.Views.Properties.PropertyFieldsetView model: model
    expect(view).to.have.property 'selectableLanguages'
    codes = view.selectableLanguages.map  (l) -> l.value
    expect(codes).to.eql langs

  describe '#render()', ->

    renderView = ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
      view.render()
      view

    beforeEach ->
      model =
        key: 'label'
        type: 'text'
        required: true
        multivalue: true
        properties: [
            value: 'car'
            lang: 'en'
            errors: {}
            persisted: false
          ]

    it 'renders container', ->
      el = renderView().$el
      expect(el).to.match 'fieldset.property'

    it 'adds class "required" in the container if property is not optional', ->
      model.required = true
      el = renderView().$el
      expect(el).to.match 'fieldset.property.required'

    it 'does not add class "required" in the container if property is optional', ->
      model.required = false
      el = renderView().$el
      expect(el).to.not.match 'fieldset.property.required'

    it 'renders the property key as a title', ->
      model.key = 'my_key'
      el = renderView().$el
      title = el.find 'h4'
      expect(title).to.contain 'my_key'

    it 'renders a remove value link for multivalued fieldsets value groups', ->
      I18n.t.withArgs('property.value.remove', {property_name: model.key}).returns 'Remove value'
      el = renderView().$el
      removeLink = el.find 'a.remove-value'
      expect(removeLink).to.contain 'Remove value'

    it 'does not render a remove value link for required non-multivalued fieldsets', ->
      model.type = 'boolean'
      model.required = true
      el = renderView().$el
      expect(el).to.not.contain 'a.remove-value'

    it 'renders a remove property link for optional non multivalued fieldsets', ->
      model.type = 'boolean'
      model.multivalue = false
      model.required = false
      I18n.t.withArgs('property.remove', {property_name: model.key}).returns 'Remove property'
      el = renderView().$el
      removeLink = el.find 'a.remove-property'
      expect(removeLink).to.contain 'Remove property'

    it 'updates remove links', ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
      sinon.stub view, 'updateRemoveLinks'
      view.render()
      expect(view.updateRemoveLinks).to.have.been.calledOnce

    it 'tranforms all select fields to their Coreon equivalent', ->
      renderView()
      expect(jQuery.fn.coreonSelect).to.have.been.calledOnce

    xit 'renders property errors', ->
      model.errors = {value: ['is invalid']}
      el = renderView()
      expect(el).to.contain 'is invalid'

    describe 'renders the proper input for value according to property type', ->

      context 'text fields', ->

        textFieldStub = null

        beforeEach ->
          textFieldStub = sinon.stub(Coreon.Helpers, 'textField')
          sinon.stub(Coreon.Helpers, 'selectField').returns '''
              <select>
                <option value="en">English</option>
                <option value="de">German</option>
                <option value="fr">French</option>
              </select>
            '''


        afterEach ->
          Coreon.Helpers.textField.restore()
          Coreon.Helpers.selectField.restore()

        it 'renders a text input field for type text', ->
          textFieldStub.withArgs(
            null,
            'properties[0][0][value]',
            value: 'car',
            required: true, errors: {}, class: 'value'
          ).returns('<input type="text"></input>')
          model.type = 'text'
          el = renderView().$el
          expect(el).to.have 'input[type=text]'
          expect(el).to.have 'select'

        it 'renders multiple text input fields when given', ->
          textFieldStub.withArgs(
            null,
            'properties[0][0][value]',
            value: 'car',
            required: true,
            errors: {},
            class: 'value'
          ).returns('<input type="text"></input>')
          textFieldStub.withArgs(
            null,
            'properties[0][1][value]',
            value: 'auto',
            required: true,
            errors: {},
            class: 'value'
          ).returns('<input type="text"></input>')
          model.type = 'text'
          model.properties.push {
            value: 'auto'
            lang: 'de'
            errors: {}
          }
          el = renderView().$el
          inputs = el.find 'input[type=text]'
          langSelects = el.find 'select'
          expect(inputs).to.have.lengthOf 2
          expect(langSelects).to.have.lengthOf 2

      context 'multiline text fields', ->

        textAreaFieldStub = null

        beforeEach ->
          textAreaFieldStub = sinon.stub(Coreon.Helpers, 'textAreaField')
          sinon.stub(Coreon.Helpers, 'selectField').returns '''
              <select>
                <option value="en">English</option>
                <option value="de">German</option>
                <option value="fr">French</option>
              </select>
            '''


        afterEach ->
          Coreon.Helpers.textAreaField.restore()
          Coreon.Helpers.selectField.restore()

        it 'renders a text area field', ->
          textAreaFieldStub.withArgs(
            null,
            'properties[0][0][value]',
            value: 'car',
            required: true, errors: {}, class: 'value'
          ).returns('<textarea></textarea>')
          model.type = 'multiline_text'
          el = renderView().$el
          expect(el).to.have 'textarea'
          expect(el).to.have 'select'

        it 'renders multiple text area fields when given', ->
          textAreaFieldStub.withArgs(
            null,
            'properties[0][0][value]',
            value: 'car',
            required: true,
            errors: {},
            class: 'value'
          ).returns('<textarea></textarea>')
          textAreaFieldStub.withArgs(
            null,
            'properties[0][1][value]',
            value: 'auto',
            required: true,
            errors: {},
            class: 'value'
          ).returns('<textarea></textarea>')
          model.type = 'multiline_text'
          model.properties.push {
            value: 'auto'
            lang: 'de'
            errors: {}
          }
          el = renderView().$el
          inputs = el.find 'textarea'
          langSelects = el.find 'select'
          expect(inputs).to.have.lengthOf 2
          expect(langSelects).to.have.lengthOf 2

      context 'asset fields', ->

        fileFieldStub = null

        beforeEach ->
          model.type = 'asset'
          model.properties = [
            persisted: false
            value:
              versions:
                thumbnail_uri: '/someuri'
          ]

          fileFieldStub = sinon.stub(Coreon.Helpers, 'fileField')
          sinon.stub(Coreon.Helpers, 'selectField').returns '''
              <select>
                <option value="en">English</option>
                <option value="de">German</option>
                <option value="fr">French</option>
              </select>
            '''


        afterEach ->
          Coreon.Helpers.fileField.restore()
          Coreon.Helpers.selectField.restore()

        it 'renders a file input field for type asset when new asset', ->
          fileFieldStub.withArgs(
            null,
            'properties[0][0][file]',
            required: true, errors: {}, class: 'file'
          ).returns('<input type="file"></input>')
          el = renderView().$el
          expect(el).to.have 'input[type=file]'
          expect(el).to.have 'input[type=hidden]'
          expect(el).to.have 'select'

        it 'renders a preview for type asset when persisted asset', ->
          model.properties[0].persisted = true
          el = renderView().$el
          expect(el).to.not.have 'input[type=file]'
          expect(el).to.have 'input[type=hidden]'
          expect(el).to.not.have 'select'

        it 'renders multiple file input fields when given', ->
          model.type = 'asset'
          model.properties[0].persisted = false
          model.properties.push {
            persisted: false
            value:
              versions:
                thumbnail_uri: '/someotheruri'
          }
          fileFieldStub.withArgs(
            null,
            'properties[0][0][file]',
            required: true,
            errors: {},
            class: 'file'
          ).returns('<input type="file"></input>')
          fileFieldStub.withArgs(
            null,
            'properties[0][1][file]',
            required: true,
            errors: {},
            class: 'file'
          ).returns('<input type="file"></input>')
          el = renderView().$el
          inputs = el.find 'input[type=file]'
          langSelects = el.find 'select'
          expect(inputs).to.have.lengthOf 2
          expect(langSelects).to.have.lengthOf 2

      context 'boolean fields', ->

        booleanFieldStub = null

        beforeEach ->
          booleanFieldStub = sinon.stub(Coreon.Helpers, 'booleanField')

        afterEach ->
          Coreon.Helpers.booleanField.restore()

        it 'renders a text input field for type boolean', ->
          model.type = 'boolean'
          model.labels = ['Yes', 'No']
          model.properties[0].value = true
          booleanFieldStub.withArgs(
            null,
            'properties[0][value]',
            value: true,
            required: false,
            errors: {},
            labels: ['Yes', 'No'],
            class: 'value'
          ).returns('<input type="radio">yes</input><input type="radio">no</input>')
          el = renderView().$el
          expect(el).to.have 'input[type=radio]'
          expect(el).not.to.have 'select'

      context 'number fields', ->

        textFieldStub = null

        beforeEach ->
          textFieldStub = sinon.stub(Coreon.Helpers, 'textField')

        afterEach ->
          Coreon.Helpers.textField.restore()

        it 'renders a text input field for type number', ->
          model.type = 'number'
          model.properties[0].value = 0.23
          textFieldStub.withArgs(
            null,
            'properties[0][value]',
            value: 0.23,
            required: true,
            errors: {},
            class: 'value'
          ).returns('<input type="text"></input>')
          el = renderView().$el
          expect(el).to.have 'input[type=text]'
          expect(el).not.to.have 'select'

      context 'date fields', ->

        textFieldStub = null

        beforeEach ->
          textFieldStub = sinon.stub(Coreon.Helpers, 'textField')

        afterEach ->
          Coreon.Helpers.textField.restore()

        it 'renders a text input field for type date', ->
          model.type = 'date'
          model.properties[0].value = '2014-03-14 12:30:00'
          textFieldStub.withArgs(
            null,
            'properties[0][value]',
            value: '2014-03-14 12:30:00',
            required: true,
            errors: {},
            class: 'value'
          ).returns('<input type="text"></input>')
          el = renderView().$el
          expect(el).to.have 'input[type=text]'

      context 'multiselect picklist', ->

        multiSelectFieldStub = null

        beforeEach ->
          multiSelectFieldStub = sinon.stub(Coreon.Helpers, 'multiSelectField')

        afterEach ->
          Coreon.Helpers.multiSelectField.restore()

        it 'renders a set of checkboxes', ->
          model.type = 'multiselect_picklist'
          model.values = ['Good', 'Bad', 'Ugly']
          model.properties[0].value = ['Bad', 'Ugly']
          multiSelectFieldStub.withArgs(
            null,
            'properties[0][value]',
            value: model.properties[0].value,
            required: false,
            errors: {},
            options: model.values,
            class: 'value'
          ).returns '''
            <input type="checkbox">Good</input>
            <input type="checkbox">Bad</input>
            <input type="checkbox">Ugly</input>
          '''
          el = renderView().$el
          checkboxes = el.find 'input[type=checkbox]'
          expect(checkboxes).to.have.lengthOf 3
          expect(el).not.to.have 'select'

      context 'picklist', ->

        selectFieldStub = null

        beforeEach ->
          selectFieldStub = sinon.stub(Coreon.Helpers, 'selectField')

        afterEach ->
          Coreon.Helpers.selectField.restore()

        it 'renders a dropdown select', ->
          model.type = 'picklist'
          model.values = ['Good', 'Bad', 'Ugly']
          model.labeled_values = [{value: 'Good', label: 'Good'}, {value: 'Bad', label: 'Bad'}, {value: 'Ugly', label: 'Ugly'}]
          model.properties[0].value = 'Bad'
          selectFieldStub.withArgs(
            null,
            'properties[0][value]',
            value: model.properties[0].value,
            required: false,
            errors: {},
            options: model.labeled_values,
            class: 'value'
          ).returns '''
            <select name='bar'>
              <option value="Good">Good</option>
              <option value="Bad" selected>Good</option>
              <option value="Ugly">Ugly</option>
            </select>
          '''
          el = renderView().$el
          select = el.find 'select'
          select_options = select.find 'option'
          expect(select_options).to.have.lengthOf 3
          expect(select.val()).to.eql 'Bad'

    describe '#serializeArray()', ->

      it 'adds _destroy attribute if property not multivalued and marked for deletion', ->
        model.multivalue = false
        view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
        view.$el = $ '''
          <fieldset>
            <div class="group delete"></div>
          </fieldset>
        '''
        properties = view.serializeArray()
        expect(properties[0]).to.have.property '_destroy'

      it 'returns the values of each set of a text property', ->
        model.type = 'text'
        model.key = 'car'
        markup = $ '''
            <fieldset>
              <div class="group">
                <input type="text">
                <select><option value="en" selected="">English</option></select>
              </div>
              <div class="group">
                <input type="text">
                <select><option value="de" selected="">German</option></select>
              </div>
            </fieldset>
          '''
        view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
        view.$el = markup
        view.$el.find('input').first().val("Honda")
        view.$el.find('input').last().val("Mazda")
        properties = view.serializeArray()
        expect(properties).to.have.lengthOf 2
        expect(properties[0]).to.have.property 'value', 'Honda'
        expect(properties[1]).to.have.property 'value', 'Mazda'

      it 'returns the values of each set of a multiline_text property', ->
        model.type = 'multiline_text'
        model.key = 'car'
        markup = $ '''
            <fieldset>
              <div class="group">
                <textarea></textarea>
                <select><option value="en" selected="">English</option></select>
              </div>
              <div class="group">
                <textarea></textarea>
                <select><option value="de" selected="">German</option></select>
              </div>
            </fieldset>
          '''
        view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
        view.$el = markup
        view.$el.find('textarea').first().val("Honda")
        view.$el.find('textarea').last().val("Mazda")
        properties = view.serializeArray()
        expect(properties).to.have.lengthOf 2
        expect(properties[0]).to.have.property 'value', 'Honda'
        expect(properties[1]).to.have.property 'value', 'Mazda'

      it 'returns the value of a boolean property', ->
        model.type = 'boolean'
        model.key = 'public'
        markup = $ '''
            <fieldset>
              <div class="group">
                <label>Yes</label>
                <input name="foo" type="radio" value="true">
                <label>No</label>
                <input name="foo" type="radio" value="false" checked>
              </div>
            </fieldset>
          '''
        view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
        view.$el = markup
        properties = view.serializeArray()
        expect(properties).to.have.lengthOf 1
        expect(properties[0]).to.have.property 'value', false

      it 'returns the value of a numerical property', ->
        model.type = 'number'
        model.key = 'vat'
        markup = $ '''
            <fieldset>
              <div class="group">
                <input name="vat" type="text" value="0.23">
              </div>
            </fieldset>
          '''
        view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
        view.$el = markup
        properties = view.serializeArray()
        expect(properties).to.have.lengthOf 1
        expect(properties[0]).to.have.property 'value', 0.23

      it 'returns null if an ivalid value is given for a numerical property', ->
        model.type = 'number'
        model.key = 'vat'
        markup = $ '''
            <fieldset>
              <div class="group">
                <input name="vat" type="text" value="0.2.3">
              </div>
            </fieldset>
          '''
        view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
        view.$el = markup
        properties = view.serializeArray()
        expect(properties).to.have.lengthOf 1
        expect(properties[0]).to.have.property 'value', null

      it 'returns the value of a date property', ->
        model.type = 'date'
        model.key = 'birthday'
        markup = $ '''
            <fieldset>
              <div class="group">
                <input name="birthday" type="text" value="2014-03-01 00:00:00">
              </div>
            </fieldset>
          '''
        view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
        view.$el = markup
        properties = view.serializeArray()
        expect(properties).to.have.lengthOf 1
        expect(properties[0]).to.have.property 'value', '2014-03-01 00:00:00'

      it 'returns the values of each multiselect checkbox', ->
        model.type = 'multiselect_picklist'
        model.key = 'personality'
        markup = $ '''
            <fieldset>
              <div class="group">
                <input type="checkbox" name="properties[0][0][value]" value="good">Good</input>
                <input type="checkbox" name="properties[0][0][value]" value="bad" checked>Bad</input>
                <input type="checkbox" name="properties[0][0][value]" value="ugly" checked>Ugly</input>
              </div>
            </fieldset>
          '''
        view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
        view.name = "properties[0][0][value]"
        view.$el = markup
        properties = view.serializeArray()
        expect(properties).to.have.lengthOf 1
        expect(properties[0].value[0]).to.eql 'bad'
        expect(properties[0].value[1]).to.eql 'ugly'

      it 'returns the value of a picklist', ->
        model.type = 'picklist'
        model.key = 'personality'
        markup = $ '''
            <fieldset>
              <div class="group">
                <select name="properties[0][0][value]">
                  <option value="Good">Good</option>
                  <option value="Bad" selected>Bad</option>
                  <option value="Ugly">Ugly</option>
                </select>
              </div>
            </fieldset>
          '''
        view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
        view.name = "properties[0][0][value]"
        view.$el = markup
        properties = view.serializeArray()
        expect(properties).to.have.lengthOf 1
        expect(properties[0].value).to.eql 'Bad'

  describe '#isValid()', ->

    view = null
    props = null

    beforeEach ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      sinon.stub view, 'serializeArray', -> props

    afterEach ->
      view.serializeArray.restore()

    it 'returns true when all values of all inputs are valid', ->
      props = [
        {key: 'label', value: 'Canteen'},
        {key: 'public', value: false},
      ]
      result = view.isValid()
      expect(result).to.be.true

    it 'returns false when even one of the values of all inputs is invalid', ->
      props = [
        {key: 'label', value: null},
        {key: 'public', value: false},
      ]
      result = view.isValid()
      expect(result).to.be.false

    it 'returns false when even one of the keys of all inputs is invalid', ->
      props = [
        {value: 'Canteen'},
        {key: 'public', value: false},
      ]
      result = view.isValid()
      expect(result).to.be.false

    it 'returns false when even one of the values of all inputs is an empty array', ->
      props = [
        {key: 'label', value: []},
        {key: 'public', value: false},
      ]
      result = view.isValid()
      expect(result).to.be.false

  describe '#checkDelete()', ->

    markup = null
    view = null

    renderView = ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      view.$el = markup

    context 'for multi-valued properties', ->

      beforeEach ->
        model.multivalue = true

      it 'returns the number of values that were marked for deletion', ->
        markup = $ '''
            <fieldset>
              <div class='group delete'></div>
              <div class='delete'></div>
              <div class='group delete'></div>
            </fieldset>
          '''
        renderView()
        deleted = view.checkDelete()
        expect(deleted).to.equal 2

      it 'returns the 0 if no values were marked for deletion', ->
        markup = $ '''
            <fieldset>
              <div class='group'></div>
              <div class='delete'></div>
              <div class='group'></div>
            </fieldset>
          '''
        renderView()
        deleted = view.checkDelete()
        expect(deleted).to.equal 0

    context 'for single valued properties', ->

      beforeEach ->
        model.multivalue = false

      it 'returns the number of values that were marked for deletion', ->
        markup = $ '''
            <fieldset>
              <div class='group delete'></div>
            </fieldset>
          '''
        renderView()
        deleted = view.checkDelete()
        expect(deleted).to.equal 0

      it 'returns the 0 if no values were marked for deletion', ->
        markup = $ '''
            <fieldset>
              <div class='group'></div>
            </fieldset>
          '''
        renderView()
        deleted = view.checkDelete()
        expect(deleted).to.equal 0

  describe '#markDelete()', ->

    it 'mark fieldset as "to delete", disable all inputs within it', ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      sinon.stub view, 'inputChanged'
      view.$el = $ '''
        <fieldset>
          <input></input>
          <textarea></textarea>
        </fidelset>
      '''
      view.markDelete()
      expect(view.$el).to.have.class 'delete'
      expect(view.$el.find('input').prop 'disabled').to.be.true
      expect(view.$el.find('textarea').prop 'disabled').to.be.true
      expect(view.inputChanged).to.have.been.calledOnce

  describe '#inputChanged()', ->

    it 'triggers an "inputChanged" event when called', ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      eventSpy = sinon.spy()
      view.on 'inputChanged', eventSpy
      view.inputChanged()
      expect(eventSpy).to.have.been.calledOnce

  describe '#addValue()', ->

    beforeEach ->
      model =
        key: 'label'
        type: 'text'
        required: true
        multivalue: true
        properties: [
            value: 'car'
            lang: 'en'
            errors: {}
        ]

    it 'appends a new value to a multivalue property', ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      sinon.stub view, 'updateRemoveLinks'
      sinon.stub view, 'inputChanged'
      view.values_index = 1
      view.$el = $ '''
        <fieldset>
          <div class="group"><input type='text'></input></div>
        </fieldset>
      '''
      view.addValue()
      groups = view.$el.find('.group')
      expect(groups.length).to.equal 2
      expect(view.values_index).to.equal 2
      expect(view.updateRemoveLinks).to.have.been.calledOnce
      expect(view.inputChanged).to.have.been.calledOnce
      expect(jQuery.fn.coreonSelect).to.have.been.calledOnce

    it 'does not work for non multivalue properties', ->
      model.multivalue = false
      Coreon.Templates = sinon.spy
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      view.values_index = 1
      view.addValue()
      expect(Coreon.Templates).to.not.have.been.called
      expect(view.values_index).to.equal 1

  describe '#removeValue()', ->

    beforeEach ->
      model =
        key: 'label'
        type: 'text'
        required: true
        multivalue: true
        properties: [
          {
            value: 'car'
            lang: 'en'
            errors: {}
            persisted: true
          },
          {
            value: 'boat'
            lang: 'en'
            errors: {}
            persisted: false
          }
        ]

    it 'removes the value inputs for non-required, non-peristed values', ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      sinon.stub view, 'inputChanged'
      view.$el = $ '''
        <fieldset>
          <div class="group" data-index="0"><a class="remove-value"><input type='text'></input></a></div>
          <div class="group" data-index="1"><a class="remove-value"><input type='text'></input></a></div>
        </fieldset>
      '''
      event = $.Event 'click'
      event.target = view.$('a.remove-value')[1]
      view.delegateEvents()
      $(view.$('a.remove-value')[1]).trigger event
      groups = view.$el.find('.group')
      expect(groups.length).to.equal 1
      expect(view.inputChanged).to.have.been.calledOnce

    it 'marks as deleted the value inputs for non-required, peristed values', ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      sinon.stub view, 'inputChanged'
      view.$el = $ '''
        <fieldset>
          <div class="group" data-index="0"><a class="remove-value"><input type='text'></input></a></div>
          <div class="group" data-index="1"><a class="remove-value"><input type='text'></input></a></div>
        </fieldset>
      '''
      event = $.Event 'click'
      event.target = view.$('a.remove-value')[0]
      view.delegateEvents()
      $(view.$('a.remove-value')[0]).trigger event
      groups = view.$el.find('.group')
      expect(groups.length).to.equal 2
      expect($(groups[0])).to.have.class 'delete'
      expect(view.inputChanged).to.have.been.calledOnce

    it 'updates remove links after deletion/removal if more - undeleted - values remain', ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      sinon.stub view, 'inputChanged'
      sinon.stub view, 'updateRemoveLinks'
      view.$el = $ '''
        <fieldset>
          <div class="group" data-index="0"><a class="remove-value"><input type='text'></input></a></div>
          <div class="group" data-index="1"><a class="remove-value"><input type='text'></input></a></div>
        </fieldset>
      '''
      event = $.Event 'click'
      event.target = view.$('a.remove-value')[0]
      view.delegateEvents()
      $(view.$('a.remove-value')[0]).trigger event
      groups = view.$el.find('.group')
      expect(groups.length).to.equal 2
      expect($(groups[0])).to.have.class 'delete'
      expect(view.inputChanged).to.have.been.calledOnce
      expect(view.updateRemoveLinks).to.have.been.calledOnce

    it 'updates remove links after deletion/removal if no - undeleted - values remain', ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      sinon.stub view, 'inputChanged'
      sinon.stub view, 'updateRemoveLinks'
      sinon.stub view, 'removeProperty'
      view.$el = $ '''
        <fieldset>
          <div class="group" data-index="0"><a class="remove-value"><input type='text'></input></a></div>
          <div class="group" data-index="1"><a class="remove-value"><input type='text'></input></a></div>
        </fieldset>
      '''
      event = $.Event 'click'
      event.target = view.$('a.remove-value')[1]
      view.delegateEvents()
      $(view.$('a.remove-value')[1]).trigger event
      event = $.Event 'click'
      event.target = view.$('a.remove-value')[0]
      view.delegateEvents()
      $(view.$('a.remove-value')[0]).trigger event
      groups = view.$el.find('.group')
      expect(groups.length).to.equal 1
      expect($(groups[0])).to.have.class 'delete'
      expect(view.inputChanged).to.have.been.calledTwice
      expect(view.updateRemoveLinks).to.have.been.calledOnce
      expect(view.removeProperty).to.have.been.calledOnce

  describe '#updateRemoveLinks()', ->

    beforeEach ->
      model =
        key: 'label'
        type: 'text'
        required: true
        multivalue: true
        properties: [
        ]
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model

    it 'shows links for multivalued required non-deleted values if more than one', ->
      view.$el = $ '''
        <fieldset>
          <div class="group" data-index="0"><a class="remove-value"><input type='text'></input></a></div>
          <div class="group" data-index="1"><a class="remove-value"><input type='text'></input></a></div>
        </fieldset>
      '''
      view.updateRemoveLinks()
      links = view.$el.find('a.remove-value')
      expect($(links[0])).to.not.have.css 'display', 'none'
      expect($(links[1])).to.not.have.css 'display', 'none'

    it 'hides links for multivalued required non-deleted values if one left', ->
      view.$el = $ '''
        <fieldset>
          <div class="group delete" data-index="0"><a class="remove-value"><input type='text'></input></a></div>
          <div class="group" data-index="1"><a class="remove-value"><input type='text'></input></a></div>
        </fieldset>
      '''
      view.updateRemoveLinks()
      links = view.$el.find('a.remove-value')
      expect($(links[0])).to.not.have.css 'display', 'none'
      expect($(links[1])).to.have.css 'display', 'none'

    it 'shows links for multivalued non-required non-deleted values if one left', ->
      model.required = false
      view.$el = $ '''
        <fieldset>
          <div class="group delete" data-index="0"><a class="remove-value"><input type='text'></input></a></div>
          <div class="group" data-index="1"><a class="remove-value"><input type='text'></input></a></div>
        </fieldset>
      '''
      view.updateRemoveLinks()
      links = view.$el.find('a.remove-value')
      expect($(links[0])).to.not.have.css 'display', 'none'
      expect($(links[1])).to.not.have.css 'display', 'none'

  describe '#removeProperty()', ->

    it 'does not trigger a "removeProperty" event if model is multivalued, optional and contains a persisted value', ->
      model =
        key: 'label'
        type: 'text'
        required: false
        multivalue: true
        properties: [
        ]
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      sinon.stub view, 'containsPersisted', -> true
      sinon.stub view, 'trigger'
      view.removeProperty()
      expect(view.trigger).to.not.have.been.called

    it 'trigger a "removeProperty" event if model by default', ->
      model =
        key: 'label'
        type: 'text'
        required: true
        multivalue: true
        properties: [
        ]
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      sinon.stub view, 'containsPersisted', -> true
      sinon.stub view, 'trigger'
      view.removeProperty()
      expect(view.trigger).to.have.been.called

  describe '#containsPersisted', ->

    it 'returns true if at least one value of the property is persisted', ->
      model =
        properties: [{persisted: true}, {persisted: false}]
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      expect(view.containsPersisted()).to.be.true

    it 'returns false if all values of the property are not persisted', ->
      model =
        properties: [{persisted: false}, {persisted: false}]
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      expect(view.containsPersisted()).to.be.false

















