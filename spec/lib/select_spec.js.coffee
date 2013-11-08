#= require spec_helper
#= require lib/select
    
describe 'Coreon.Lib.Select', ->
  
  beforeEach ->
    @select = $('<select name="some_value" class="my-selector"><option value="a">The Letter A</option><option value="1" selected>The Number One</option></select>')
      
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
      
    it 'tranfers the css class to the CoreonSelect', ->
      @subject.render()
      expect( @subject.$el.attr('class') ).to.equal 'coreon-select my-selector'
      
    it 'tranfers the name attribute to the CoreonSelect´s data-select-name', ->
      @subject.render()
      expect( @subject.$el.attr('data-select-name') ).to.equal 'some_value'
      
    it 'displays the label of the selected option', ->
      @subject.render()
      expect( @subject.$el.text() ).to.equal 'The Number One'
      
    it 'hides the original select', ->
      @subject.render()
      expect( @subject.$el ).to.be.hidden

    it 'sets single class if only one option exist', ->
      select = $('<select><option value="x">X</option></select>')
      subject = new Coreon.Lib.Select select
      subject.render()
      expect( subject.$el ).to.have.class 'single'
    
  describe '_buildSelectOptions()', ->
    
    it 'parses given select options to array of tuples', ->
      @subject._buildSelectOptions()
      expect( @subject.selectOptions ).to.eql [
        ["a", "The Letter A"]
        ["1", "The Number One"]
      ]
    
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
      
      @popup = 
        $: (query) =>
          @listEl if query == 'ul'
        render: -> @
        $el: @el
        remove: -> @
      
      sinon.stub Coreon.Lib, 'SelectPopup', => @popup
      
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
        
    it 'prompts the dropdown view', ->
      @subject.prompt = sinon.spy()
      @subject.showDropdown()
      expect( @subject.prompt ).to.be.calledOnce
      expect( @subject.prompt.firstCall.args[0]).to.equal @popup
      
    
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