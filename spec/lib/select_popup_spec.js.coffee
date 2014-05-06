#= require spec_helper
#= require lib/select_popup

describe 'Coreon.Lib.SelectPopup', ->

  beforeEach ->
    @widget =
      changeTo: () ->
        true

    @viewParams =
      widget: @widget
      value: '2'
      selectOptions: [
        ['1', 'One']
        ['2', 'Two']
        ['3', 'Three']
      ]
      widgetClasses: 'my-selector my-widget'


    @view = new Coreon.Lib.SelectPopup @viewParams

  it 'is a Backbone view', ->
    expect( @view ).to.be.an.instanceof Backbone.View

  it 'creates container', ->
    expect( @view.$el ).to.have.class 'coreon-select-dropdown'

  describe 'initialize()', ->

    it 'assigns widget', ->
      expect( @view.widget ).to.equal @widget

    it 'assigns value', ->
      expect( @view.value ).to.equal '2'

    it 'assigns selectOptions', ->
      expect( @view.selectOptions ).to.be.deep.equal [
        ['1', 'One']
        ['2', 'Two']
        ['3', 'Three']
      ]

  describe 'render()', ->

    it 'is chainable', ->
      expect( @view.render() ).to.equal @view

    it 'renders an options list', ->
      @view.render()
      expect( @view.$('ul.options').length ).to.equal 1

    it 'renders the "One" option item as first', ->
      @view.render()
      item = $ @view.$('ul.options li.option')[0]
      expect( item.attr('data-value') ).to.equal '1'
      expect( item.text() ).to.equal 'One'
      expect( item ).not.to.have.class 'selected'

    it 'renders the "Two" option item as second marked as selected', ->
      @view.render()
      item = $ @view.$('ul.options li.option')[1]
      expect( item.attr('data-value') ).to.equal '2'
      expect( item.text() ).to.equal 'Two'
      expect( item ).to.have.class 'selected'

    it 'renders the "Three" option item as third', ->
      @view.render()
      item = $ @view.$('ul.options li.option')[2]
      expect( item.attr('data-value') ).to.equal '3'
      expect( item.text() ).to.equal 'Three'
      expect( item ).not.to.have.class 'selected'

    it 'adds the widgetClasses to the container', ->
      expect( @view.$el ).to.have.class 'coreon-select-dropdown'
      expect( @view.$el ).not.to.have.class 'my-selector'
      expect( @view.$el ).not.to.have.class 'my-widget'
      @view.render()
      expect( @view.$el ).to.have.class 'coreon-select-dropdown'
      expect( @view.$el ).to.have.class 'my-selector'
      expect( @view.$el ).to.have.class 'my-widget'

  describe 'setItem()', ->

    it 'is chainable', ->
      expect( @view.setItem(@view.$('ul.options li.option:first')) ).to.equal @view

    it 'calls changeTo on the widget', ->
      @stub @widget, 'changeTo'
      @view.render()
      @view.setItem(@view.$('ul.options li.option:first'))
      expect( @widget.changeTo ).to.be.calledWith(1, 'One')


  describe 'focusItem()', ->

    it 'is chainable', ->
      expect( @view.focusItem() ).to.equal @view

    it 'puts focus CSS class to given element', ->
      @view.render()
      focussed = @view.$('ul.options li:first')
      focussed.addClass('focus')

      @view.focusItem( @view.$('ul.options li:last') )

      expect( focussed ).not.to.have.class 'focus'
      expect( @view.$('ul.options li:last') ).to.have.class 'focus'

    it 'removes all focus if called with no param', ->
      @view.render()
      focussed = @view.$('ul.options li:first')
      focussed.addClass('focus')

      @view.focusItem()

      expect( @view.$('ul.options li.focus').length ).to.equal 0

  describe 'remove()', ->

    describe 'with stubbed remove', ->
      beforeEach ->
        @stub Coreon.Lib.SelectPopup::, 'remove', -> @

      it 'is called by click on $el', ->
        view = new Coreon.Lib.SelectPopup @viewParams
        view.render()
        view.$el.trigger 'click'

        expect( view.remove ).to.be.calledOnce

    it 'is chainable', ->
      expect( @view.remove() ).to.equal @view

  describe 'onItemClick()', ->

    describe 'with spy on onItemClick', ->

      beforeEach ->
        @spy Coreon.Lib.SelectPopup::, 'onItemClick'

      it 'is called by click on li', ->
        view = new Coreon.Lib.SelectPopup @viewParams
        view.render()
        view.$('li:first').click()

        expect( view.onItemClick ).to.be.calledOnce

      it 'is called by click on span in li', ->
        view = new Coreon.Lib.SelectPopup @viewParams
        view.render()
        view.$('li:first span').click()

        expect( view.onItemClick ).to.be.calledOnce

    context 'with spy on setItem', ->
      beforeEach ->
        @spy @view, 'setItem'

      it 'finds li element when span in li was clicked', ->
        @view.render()
        @view.onItemClick
          target: @view.$('li:first span')

        expect( @view.setItem ).to.be.calledOnce
        expect( @view.setItem.firstCall.args[0] ).to.be @view.$('li:first')

  describe 'onItemFocus()', ->

    describe 'with spy on onItemFocus', ->
      beforeEach ->
        @spy Coreon.Lib.SelectPopup::, 'onItemFocus'

      it 'is called by mouse over li', ->
        view = new Coreon.Lib.SelectPopup @viewParams
        view.render()
        view.$('li:first').mouseover()

        expect( view.onItemFocus ).to.be.calledOnce

      it 'is called by mouse over span in li', ->
        view = new Coreon.Lib.SelectPopup @viewParams
        view.render()
        view.$('li:first span').mouseover()

        expect( view.onItemFocus ).to.be.calledOnce

    describe 'with spy on @focusItem', ->

      beforeEach ->
        @spy @view, 'focusItem'

      it 'calls @focusItem with no param if event target is li', ->
        @view.render()
        @view.onItemFocus
          target: @view.$('li:first')

        expect( @view.focusItem ).to.be.calledOnce
        expect( @view.focusItem.firstCall.args[0] ).to.be @view.$('li:first')

      it 'calls @focusItem with no param if event target is span in li', ->
        @view.render()
        @view.onItemFocus
          target: @view.$('li:first span')

        expect( @view.focusItem ).to.be.calledOnce
        expect( @view.focusItem.firstCall.args[0] ).to.be @view.$('li:first')

  describe 'onItemBlur()',->

    describe 'with spy on onItemBlur', ->

      beforeEach ->
        @spy Coreon.Lib.SelectPopup::, 'onItemBlur'

      it 'is called by click mouse out li', ->
        view = new Coreon.Lib.SelectPopup @viewParams
        view.render()
        view.$('li:first').mouseout()

        expect( view.onItemBlur ).to.be.calledOnce

      it 'is called by click mouse out span in li', ->
        view = new Coreon.Lib.SelectPopup @viewParams
        view.render()
        view.$('li:first span').mouseout()

        expect( view.onItemBlur ).to.be.calledOnce

    describe 'with spy on @focusItem', ->
      beforeEach ->
        @spy @view, 'focusItem'

      it 'calls @focusItem with no param', ->
        @view.render()
        @view.onItemBlur
          target: @view.$('li:first')

        expect( @view.focusItem ).to.be.calledOnce

  describe 'onKeydown()', ->

    describe 'with spy on onKeydown', ->

      beforeEach ->
        @spy @view, 'onKeydown', -> @

      it 'is called by pressing a key', ->
        @view.render()
        $(document).trigger('keydown', 20)

        expect( @view.onKeydown ).to.be.calledOnce
