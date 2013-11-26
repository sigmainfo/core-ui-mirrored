#= require spec_helper
#= require views/widgets/term_list_view

describe 'Coreon.Views.Widgets.TermListView', ->

  beforeEach ->
    sinon.stub I18n, "t"
    @view = new Coreon.Views.Widgets.TermListView

  afterEach ->
    I18n.t.restore()

  it 'is a Backbone view', ->
    expect( @view ).to.be.an.instanceof Backbone.View

  it 'creates container', ->
    expect( @view.$el ).to.have.id 'coreon-term-list'
    expect( @view.$el ).to.have.class 'widget'

  describe '#initialize()', ->

    it 'renders markup', ->
      I18n.t.withArgs('widgets.term_list.title').returns 'Term List'
      @view.initialize()
      expect( @view.$el ).to.have '.titlebar h4'
      expect( @view.$ '.titlebar h4' ).to.have.text 'Term List'
