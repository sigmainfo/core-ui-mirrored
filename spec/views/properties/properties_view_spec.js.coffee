#= require spec_helper
#= require views/properties/properties_view

describe 'Coreon.Views.Properties.PropertiesView', ->

  app = null
  view = null
  collection = null

  beforeEach ->
    app = langs: -> []
    collection = new Backbone.Collection
    view = new Coreon.Views.Properties.PropertiesView
      model: collection
      app: app

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'creates container', ->
    el = view.$el
    expect(el).to.match 'section.properties'

  describe '#initialize()', ->

    it 'sets app from options', ->
      app2 = new Backbone.Model
      view.initialize app: app2
      assigned = view.app
      expect(assigned).to.equal app2

    it 'defaults app to singleton instance', ->
      app2 = new Backbone.Model
      Coreon.application = app2
      try
        view.initialize()
        assigned = view.app
        expect(assigned).to.equal app2
      finally
        delete Coreon.application

    it 'sets template from options', ->
      template = ->
      view.initialize template: template
      assigned = view.template
      expect(assigned).to.equal template

    it 'sets default template when not given', ->
      view.initialize()
      assigned = view.template
      expect(assigned).to.equal Coreon.Templates['properties/properties']

  describe '#render()', ->

    template = null

    beforeEach ->
      template = @stub()
      view.template = template

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    it 'is triggered by changes on collection', ->
      render = @spy()
      view.render = render
      view.initialize()
      collection.trigger 'change'
      expect(view.render).to.have.been.calledOnce

    context 'template', ->

      it 'updates content from template', ->
        view.$el.html '<table class="old">deprecated</table>'
        template.returns '''
          <table class="properties">
            <tr>
              <th>description</th>
              <td>A rose is a rose is a rose.</td>
            </tr>
          </table>
        '''
        view.render()
        updated = view.$('table.properties td')
        expect(updated).to.exist
        expect(updated).to.have.text 'A rose is a rose is a rose.'
        old = view.$('table.old')
        expect(old).to.not.exist

      context 'properties', ->

        it 'groups properties by key', ->
          collection.reset [ key: 'source', value: 'WWW' ], silent: yes
          [property] = collection.models
          view.render()
          expect(template).to.have.been.calledOnce
          expect(template).to.have.been.calledWith
            properties: [
              key: 'source', properties: [property]
            ]

        context 'langs', ->

          beforeEach ->
            collection.reset [
              {key: 'gender', lang: 'en', value: 'male'}
              {key: 'gender', lang: 'de', value: 'männlich'}
              {key: 'gender', lang: 'la', value: 'masculinum'}
              {key: 'gender', lang: 'de', value: 'maskulin'}
            ], silent: yes

          it 'sorts lists by lang', ->
            app.langs = -> ['de', 'en', 'la']
            view.render()
            list = template.firstCall.args[0].properties[0].properties
            langs = list.map (property) -> property.get 'lang'
            expect(langs).to.eql ['de', 'de', 'en', 'la']

          it 'appends properties with unknown lang', ->
            app.langs = -> ['en', 'de']
            view.render()
            list = template.firstCall.args[0].properties[0].properties
            langs = list.map (property) -> property.get 'lang'
            expect(langs).to.eql ['en', 'de', 'de', 'la']
