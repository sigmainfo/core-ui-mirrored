#= require spec_helper
#= require templates/properties/properties

describe 'Coreon.Templates[properties/properties]', ->

  template = Coreon.Templates['properties/properties']
  data = null

  render = ->
    $('<div>').html(template data)

  beforeEach ->
    data =
      properties: []
      can: -> no
      action_for: -> ''
      render: -> ''

  context 'caption', ->

    it 'renders toggle', ->
      I18n.t.withArgs('properties.title').returns 'Properties'
      el = render()
      toggle = el.find('h3')
      expect(toggle).to.exist
      expect(toggle).to.have.text 'Properties'


    it 'renders tooltip', ->
      I18n.t.withArgs('properties.toggle').returns 'Toggle properties'
      el = render()
      toggle = el.find('h3')
      expect(toggle).to.have.attr 'title', 'Toggle properties'

  context 'edit', ->

    can = null
    action_for = null

    edit = (el) -> el.find '.edit-actions'

    beforeEach ->
      can = @stub data, 'can'
      action_for = @stub data, 'action_for'

    context 'with maintainer privileges', ->

      beforeEach ->
        can.withArgs('manage').returns yes

      it 'renders edit mode toggle', ->
        action_for.withArgs('properties.edit-properties')
          .returns '<a class="edit-properties">Edit properties</a>'
        el = render()
        expect(edit el).to.have 'a.edit-properties'

    context 'without maintainer privileges', ->

      beforeEach ->
        can.withArgs('manage').returns no

      it 'does not render edit division', ->
        el = render()
        expect(edit el).to.not.exist


  context 'property group', ->

    property = null

    beforeEach ->
      property = new Backbone.Model key: 'genus', value: 'male'
      data.properties = [ key: 'genus', properties: [property] ]

    it 'renders label', ->
      el = render()
      th = el.find('div table tr th')
      expect(th).to.exist
      expect(th).to.have.text 'genus'

    it 'renders cell', ->
      el = render()
      td = el.find('div table tr td')
      expect(td).to.exist

    context 'single property', ->

      beforeEach ->
        data.properties[0].properties = [property]

      context 'no lang', ->

        beforeEach ->
          property.set 'lang', null, silent: yes

        it 'does not render tab', ->
          el = render()
          index = el.find('ul.index')
          expect(index).to.not.exist
          values = el.find('ul.values')
          expect(values).to.not.exist

        it 'renders value', ->
          helper = @stub()
          data.render = helper
          helper
            .withArgs('properties/property', property: property)
            .returns '''
              <div class="value">male</div>
            '''
          el = render()
          td = el.find('div table tr td')
          value = td.find('div.value')
          expect(value).to.exist

      context 'with lang', ->

        beforeEach ->
          property.set 'lang', 'hu', silent: yes

        it 'renders tab', ->
          el = render()
          td = el.find('div table tr td')
          tab = td.find('ul.index li')
          expect(tab).to.exist
          expect(tab).to.have.text 'hu'
          expect(tab).to.have.attr 'data-index', '0'

        it 'renders value', ->
          helper = @stub()
          data.render = helper
          helper
            .withArgs('properties/property', property: property)
            .returns '''
              <div class="value">male</div>
            '''
          el = render()
          td = el.find('div table tr td')
          value = td.find('ul.values li div.value')
          expect(value).to.exist

    context 'multiple properties', ->

      property2 = null

      beforeEach ->
        property2 = new Backbone.Model key: 'genus', value: 'm'
        data.properties[0].properties = [property, property2]

      it 'renders tabs', ->
        el = render()
        td = el.find('div table tr td')
        tabs = td.find('ul.index li')
        expect(tabs).to.have.lengthOf 2
        tab2 = tabs.eq(1)
        expect(tab2).to.have.attr 'data-index', '1'

      it 'displays lang in tab', ->
        property2.set 'lang', 'hu', silent: yes
        el = render()
        td = el.find('div table tr td')
        tabs = td.find('ul.index li')
        tab2 = tabs.eq(1)
        expect(tab2).to.have.text 'hu'

      it 'displays position in tab when no lang is given', ->
        property2.set 'lang', null, silent: yes
        el = render()
        td = el.find('div table tr td')
        tabs = td.find('ul.index li')
        tab2 = tabs.eq(1)
        expect(tab2).to.have.text '2'

      it 'renders values', ->
        helper = @stub()
        data.render = helper
        helper
          .withArgs('properties/property', property: property2)
          .returns '''
            <div class="value">m</div>
          '''
        el = render()
        td = el.find('div table tr td')
        values = td.find('ul.values li')
        expect(values).to.have.lengthOf 2
        value2 = values.eq(1).find '.value'
        expect(value2).to.exist
        expect(value2).to.have.text 'm'
