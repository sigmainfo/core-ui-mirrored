#= require spec_helper
#= require lib/select
    
describe 'Coreon.Lib.Select', ->
  
  beforeEach ->
    @select = $('<select class="my-selector"><option value="a">The Letter A</option><option value="1" selected>The Number One</option></select>')
      
    @subject = new Coreon.Lib.Select @select
    
  describe 'constructor()', ->
    
    it 'assigns $select', ->
      subject = new Coreon.Lib.Select @select
      
      expect( subject.$select ).to.equal @select
      
    it 'assigns options', ->
      options = 
        some: 'options'
        should: 'be passed'
      subject = new Coreon.Lib.Select @select, options 
      
      expect( subject.options  ).to.equal options 
      
    describe 'with stubbed Coreon.Lib.Select.prototype.render', ->
      
      beforeEach ->
        sinon.stub Coreon.Lib.Select.prototype, 'render', ->
          'rendered'
          
      afterEach ->
        Coreon.Lib.Select.prototype.render.restore()
        
      it 'calls render', ->
        subject = new Coreon.Lib.Select @select
        expect( Coreon.Lib.Select.prototype.render ).to.be.called

        
    it 'sets the base $el', ->
      expect( @subject.$el ).to.have.class "coreon-select"
      
  describe 'render()', ->
    
    it 'can be chained', ->
      expect( @subject.render() ).to.equal @subject
      
    xit 'render details'
    
  describe 'changeTo()', ->
    
    it 'is chainable', ->
      expect( @subject.changeTo() ).to.equal @subject
    
    describe 'with stubbed $el', ->
      
      beforeEach ->
        sinon.spy @subject.$el, 'text'
        
      afterEach ->
        @subject.$el.text.restore()
    
      it 'sets the label', ->
        @subject.changeTo('some_value', 'Some Label')
        expect( @subject.$el.text ).to.be.calledWith('Some Label')
       
      
    describe 'with stubbed @select', ->
      
      beforeEach ->
        sinon.spy @select, 'val'
        sinon.spy @select, 'change'
        
      afterEach ->
        @select.val.restore()
        @select.change.restore()
        
      it 'sets the select and triggers change event', ->
        @subject.changeTo('some_value', 'Some Label')
        expect( @select.val ).to.be.calledWith('some_value')
        expect( @select.change ).to.be.called
    
    
  describe 'showDropdown', ->
    beforeEach ->
      @listEl = 
        position: sinon.spy()
              
      @el = 'ELEMENT'
      
      sinon.stub Coreon.Lib, 'SelectPopup', =>
        $: (query) =>
          @listEl if query == 'ul'
        render: -> @
        $el: @el
        remove: -> @
      
    afterEach ->
      Coreon.Lib.SelectPopup.restore()
      
    it 'is chainable', ->
      expect( @subject.showDropdown() ).to.equal @subject
      
    it 'creates new SelectPopup', ->
      @subject.showDropdown()
      expect( Coreon.Lib.SelectPopup ).to.be.calledWith
        widget: @subject
        value: "1"
        selectOptions: [["a", "The Letter A"], ["1", "The Number One"]]
        widgetClasses: "my-selector"
        
    it 'aligns position to select element', ->
      @subject.showDropdown()
      expect( @listEl.position ).to.be.calledWith
        at: "left bottom",
        my: "left top",
        of: $ @subject.$el
        
    xit 'prompts the view'
      
    
  describe 'jQuery.coreonSelect', ->
  
    beforeEach ->
      sinon.stub Coreon.Lib, "Select"
      
    afterEach ->
      Coreon.Lib.Select.restory
  
    it 'applies CoreonSelect to given select', ->
      Coreon.Lib.Select
      
      select = $('<select>')
      select.coreonSelect options: true
      
      expect( Coreon.Lib.Select).to.be.calledWith $ select[0], options: true