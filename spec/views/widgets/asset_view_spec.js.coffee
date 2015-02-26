#= require spec_helper
#= require views/widgets/asset_view

describe 'Coreon.Views.Widgets.AssetView', ->

  view = null
  collection = null
  el = null

  describe 'view', ->

    beforeEach ->
      collection = new Backbone.Collection
      view = new Coreon.Views.Widgets.AssetView
        collection: collection

    it 'is a Backbone view', ->
      expect(view).to.be.an.instanceOf Backbone.View

    it 'creates container', ->
      container = view.$el
      expect(container).to.match '#asset-view'

    it 'has a template', ->
      expect(view.template).to.exist

  describe '#initialize', ->

    beforeEach ->
      collection = new Backbone.Collection
      view = new Coreon.Views.Widgets.AssetView
        collection: collection

    it 'accepts an asset collection', ->
      expect(view.collection).to.be.instanceOf Backbone.Collection

  describe '#render', ->

    beforeEach ->
      collection = new Backbone.Collection [
        {uri: '/first', preview_uri: '/first_preview', info: 'caption 1', index: 0},
        {uri: '/second', preview_uri: '/second_preview', info: 'caption 2', index: 1},
        {uri: '/third', preview_uri: '/third_preview', info: 'caption 3', index: 2}
      ]
      view = new Coreon.Views.Widgets.AssetView
        collection: collection
        current: 1
      el = view.render().$el

    it 'renders a navigation header', ->
      expect(el).to.have '.navigation'

    it 'renders an asset viewer', ->
      expect(el).to.have '.preview'

    it 'renders an info panel', ->
      info = el.find('.info')
      expect(info).to.contain 'caption 2'

    it 'renders the current image', ->
      preview = el.find('.preview')
      expect(preview).to.have 'img[src="/second_preview"]'

    it 'renders a download button for the current image', ->
      download = el.find('.download > a')
      expect(download).to.have.attr 'href', '/second'
      expect(download).to.have.attr 'download'

    it 'renders previous button', ->
      previous = el.find('a.previous')
      expect(previous).to.exists

    it 'renders next button', ->
      previous = el.find('a.next')
      expect(previous).to.exists

    it 'renders close button', ->
      close = el.find('close a')
      expect(close).to.exists

  describe '#next', ->

    beforeEach ->
      collection = new Backbone.Collection [
        {uri: '/first', preview_uri: '/first_preview', index: 0},
        {uri: '/second', preview_uri: '/second_preview', index: 1},
        {uri: '/third', preview_uri: '/third_preview', index: 2}
      ]
      view = new Coreon.Views.Widgets.AssetView
        collection: collection
        current: 0
      el = view.render().$el

    it 'renders next image', ->
      view.next()
      preview = el.find('.preview')
      download = el.find('.download > a')
      expect(preview).to.have 'img[src="/second_preview"]'
      expect(download).to.have.attr 'href', '/second'

    it 'renders first image when last reached', ->
      view.current = 2
      view.next()
      preview = el.find('.preview')
      download = el.find('.download > a')
      expect(preview).to.have 'img[src="/first_preview"]'
      expect(download).to.have.attr 'href', '/first'

  describe '#previous', ->

    beforeEach ->
      collection = new Backbone.Collection [
        {uri: '/first', preview_uri: '/first_preview', index: 0},
        {uri: '/second', preview_uri: '/second_preview', index: 1},
        {uri: '/third', preview_uri: '/third_preview', index: 2}
      ]
      view = new Coreon.Views.Widgets.AssetView
        collection: collection
        current: 1
      el = view.render().$el

    it 'renders previous image', ->
      view.previous()
      preview = el.find('.preview')
      download = el.find('.download > a')
      expect(preview).to.have 'img[src="/first_preview"]'
      expect(download).to.have.attr 'href', '/first'

    it 'renders last image when last reached', ->
      view.current = 0
      view.previous()
      preview = el.find('.preview')
      download = el.find('.download > a')
      expect(preview).to.have 'img[src="/third_preview"]'
      expect(download).to.have.attr 'href', '/third'







