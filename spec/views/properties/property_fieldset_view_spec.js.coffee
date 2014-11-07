#= require spec_helper
#= require views/properties/property_fieldset_view
#= require templates/properties/property_fieldset

describe 'Coreon.Views.Properties.PropertyFieldsetView', ->

  view = null
  el = null
  model = null
  index = 0
  scopePrefix = null
  langs = [
        {value: 'en', label: 'English'},
        {value: 'de', label: 'German'},
        {value: 'fr', label: 'French'}
      ]

  beforeEach ->
    sinon.stub I18n, 't'
    Coreon.Models.RepositorySettings = sinon.stub
    Coreon.Models.RepositorySettings.languageOptions = -> langs


  afterEach ->
    I18n.t.restore()

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
    expect(view.selectableLanguages).to.eql langs

  describe '#render()', ->

    renderView = ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
      view.render()
      view

    beforeEach ->
      sinon.stub jQuery.fn, 'coreonSelect'
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

    afterEach ->
      jQuery.fn.coreonSelect.restore()

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

      it 'returns and empty array if property not multivalued and marked for deletion', ->
        model.multivalue = false
        view = new Coreon.Views.Properties.PropertyFieldsetView model: model, index: index, scopePrefix: scopePrefix
        sinon.stub(view, 'checkDelete').returns 1
        properties = view.serializeArray()
        expect(properties).to.be.empty

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

    it 'returns false when even one of the values of all inputs is empty', ->
      props = [
        {key: 'label', value: ''},
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

    it 'adds class "delete" to a fieldset to mark it ready for deletion', ->
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      view.$el = $ '''
        <fieldset>
        </fidelset>
      '''
      view.markDelete()
      expect(view.$el).to.have.class 'delete'

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

    it 'does not work for non multivalue properties', ->
      model.multivalue = false
      Coreon.Templates = sinon.spy
      view = new Coreon.Views.Properties.PropertyFieldsetView model: model
      view.values_index = 1
      view.addValue()
      expect(Coreon.Templates).to.not.have.been.called
      expect(view.values_index).to.equal 1











