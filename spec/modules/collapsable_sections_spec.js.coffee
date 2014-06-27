#= require spec_helper
#= require modules/collapsable_sections

describe 'Coreon.Modules.CollapsableSections', ->

  before ->
    class Coreon.Views.ViewWithCollapsableSections extends Backbone.View
      _(@::).extend Coreon.Modules.CollapsableSections

  after ->
    delete Coreon.Views.ViewWithCollapsableSections

  view = null
  section = null

  fakeSection = (name) ->
    $ "<section class=\"#{name}\">"

  beforeEach ->
    view = new Coreon.Views.ViewWithCollapsableSections
    section = fakeSection('items')

  describe '#findSection()', ->

    beforeEach ->
      section.appendTo view.el

    it 'defaults to section with matching class name', ->
      found = view.findSection 'items'
      expect(found).to.match section

  describe '#collapseSection()', ->

    collapsed = (view) ->
      view.collapsedSections()

    beforeEach ->
      section.appendTo "#konacha"
      view.findSection = -> section

    it 'classifies collapsed section', ->
      view.collapseSection 'items'
      expect(section).to.have.class 'collapsed'

    it 'hides content', ->
      view.sectionHeading = ''
      content = $('<div>').appendTo section
      view.collapseSection 'items'
      expect(content).to.be.hidden

    it 'does not hide heading', ->
      view.sectionHeading = 'h4'
      heading = $('<h4>ITEMS</h4>').appendTo section
      view.collapseSection 'items'
      expect(heading).to.be.visible

    it 'stores name inside collapsed sections', ->
      view.collapseSection 'items'
      expect(collapsed view).to.eql ['items']

    it 'stores name only once', ->
      view.collapseSection 'items'
      view.collapseSection 'items'
      expect(collapsed view).to.eql ['items']

  describe '#expandSection()', ->

    beforeEach ->
      section.appendTo "#konacha"
      view.findSection = -> section

    it 'classifies expanded section', ->
      section.addClass 'collapsed'
      view.expandSection 'items'
      expect(section).to.not.have.class 'collapsed'

    it 'reveals content', ->
      view.sectionHeading = ''
      content = $('<div>').hide().appendTo section
      view.expandSection 'items'
      expect(content).to.be.visible

    it 'does not reveal hidden heading', ->
      view.sectionHeading = 'h4'
      heading = $('<h4>ITEMS</h4>').hide().appendTo section
      view.expandSection 'items'
      expect(heading).to.be.hidden

    it 'removes name from collapsed sections', ->
      collapsed = ['items', 'other']
      view.collapsedSections = -> collapsed
      view.expandSection 'items'
      expect(collapsed).to.eql ['other']

  describe '#toggleSection()', ->

    collapsed = null

    beforeEach ->
      view.collapsedSections = -> collapsed

    context 'expanded', ->

      beforeEach ->
        collapsed = []

      it 'collapses section', ->
        collapseSection = sinon.stub view, 'collapseSection'
        view.toggleSection 'items'
        expect(collapseSection).to.have.been.calledOnce
        expect(collapseSection).to.have.been.calledWith 'items'

    context 'collapsed', ->

      beforeEach ->
        collapsed = ['items']

      it 'expands section', ->
        expandSection = sinon.stub view, 'expandSection'
        view.toggleSection 'items'
        expect(expandSection).to.have.been.calledOnce
        expect(expandSection).to.have.been.calledWith 'items'

  describe '#restoreCollapsedSections()', ->

    collapsed = null

    beforeEach ->
      view.collapsedSections = -> collapsed

    it 'collapses collapsed section', ->
      collapsed = ['items']
      collapseSection = sinon.stub view, 'collapseSection'
      view.restoreCollapsedSections()
      expect(collapseSection).to.have.been.calledOnce
      expect(collapseSection).to.have.been.calledWith 'items', duration: 0
