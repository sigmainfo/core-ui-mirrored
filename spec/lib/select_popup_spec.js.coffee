#= require spec_helper
#= require lib/select_popup

describe 'Coreon.Lib.SelectPopup', ->
  
  beforeEach ->
    @widget = 
      $select: 
        attr: ->
        val: ->
      
    @view = new Coreon.Lib.SelectPopup 
      widget: @widget
      value: '2'
      selectOptions: [
        ['1', 'One']
        ['2', 'Two']
        ['3', 'Three']
      ]
      
  it 'is a Backbone view', ->
    expect( @view ).to.be.an.instanceof Backbone.View

  it 'creates container', ->
    expect( @view.$el ).to.have.class 'coreon-select-dropdown'
  
  
  describe 'render()', ->
    
    it 'is chainable', ->
      expect( @view.render() ).to.equal @view
    
    
  describe 'remove()', ->
  
  describe 'focusItem()', ->
    
  describe 'onItemClick()', ->
    
  describe 'onItemFocus()', ->
    
  describe 'onItemBlur()',->
    
  describe 'onKeydown()', ->