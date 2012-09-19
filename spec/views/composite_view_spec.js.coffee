#= require spec_helper
#= require views/composite_view

describe "Coreon.Views.CompositeView", ->

  beforeEach ->
    @view = new Coreon.Views.CompositeView
    @subview = @subview1 = new Coreon.Views.SimpleView
    @subview2 = new Coreon.Views.SimpleView

  afterEach ->
    view.destroy() for view in [@view, @subview1, @subview2]

  it "is a Coreon view", ->
    @view.should.be.an.instanceof Coreon.Views.SimpleView

  it "creates an empty subview collection by default", ->
    @view.subviews.should.eql []

  describe "#append", ->
    
    it "adds subview to collection", ->
      @view.append @subview
      @view.subviews.should.have.length 1
      @view.subviews[0].should.equal @subview

    it "appends el", ->
      @view.$el.append = sinon.spy()
      @view.append @subview
      @view.$el.append.should.have.been.calledWith @subview.$el

    it "calls delegateEvents on subview", ->
      @subview.delegateEvents = sinon.spy()
      @view.append @subview
      @subview.delegateEvents.should.have.been.calledOnce

    describe "#prepend", ->

    it "adds subview to collection", ->
      @view.prepend @subview
      @view.subviews.should.have.length 1
      @view.subviews[0].should.equal @subview

    it "prepends el", ->
      @view.$el.prepend = sinon.spy()
      @view.prepend @subview
      @view.$el.prepend.should.have.been.calledWith @subview.$el

    it "calls delegateEvents on subview", ->
      @subview.delegateEvents = sinon.spy()
      @view.prepend @subview
      @subview.delegateEvents.should.have.been.calledOnce

  describe "#render", ->

    beforeEach ->
      @view.subviews = [@subview1, @subview2]
    
    it "can be chained", ->
      @view.render().should.equal @view

    it "calls render on every subview", ->
      @subview1.render = sinon.spy()
      @subview2.render = sinon.spy()
      @view.render()
      @subview1.render.should.have.been.calledOnce
      @subview2.render.should.have.been.calledOnce

    it "calls super", ->
      sinon.spy Coreon.Views.SimpleView::, "render"
      try
        @view.render()
        Coreon.Views.SimpleView::render.should.have.been.calledOn @view
      finally
        Coreon.Views.SimpleView::render.restore()

  describe "#delegateEvents", ->

    beforeEach ->
      @view.subviews = [@subview1, @subview2]
    
    it "can be chained", ->
      @view.delegateEvents().should.equal @view

    it "calls delegateEvents on every subview", ->
      @subview1.delegateEvents = sinon.spy()
      @subview2.delegateEvents = sinon.spy()
      @view.delegateEvents()
      @subview1.delegateEvents.should.have.been.calledOnce
      @subview2.delegateEvents.should.have.been.calledOnce

    it "calls super", ->
      sinon.spy Coreon.Views.SimpleView::, "delegateEvents"
      try
        @view.delegateEvents()
        Coreon.Views.SimpleView::delegateEvents.should.have.been.calledOn @view
      finally
        Coreon.Views.SimpleView::delegateEvents.restore()

    it "passes arguments to calls", ->
      method = ->
      sinon.spy Coreon.Views.SimpleView::, "delegateEvents"
      try
        @view.delegateEvents "click": method
        Coreon.Views.SimpleView::delegateEvents.should.always.have.been.calledWithExactly "click": method
      finally
        Coreon.Views.SimpleView::delegateEvents.restore()


  describe "#undelegateEvents", ->

    beforeEach ->
      @view.subviews = [@subview1, @subview2]
    
    it "can be chained", ->
      @view.undelegateEvents().should.equal @view

    it "calls undelegateEvents on every subview", ->
      @subview1.undelegateEvents = sinon.spy()
      @subview2.undelegateEvents = sinon.spy()
      @view.undelegateEvents()
      @subview1.undelegateEvents.should.have.been.calledOnce
      @subview2.undelegateEvents.should.have.been.calledOnce


    it "calls super", ->
      sinon.spy Coreon.Views.SimpleView::, "undelegateEvents"
      try
        @view.undelegateEvents()
        Coreon.Views.SimpleView::undelegateEvents.should.have.been.calledOn @view
      finally
        Coreon.Views.SimpleView::undelegateEvents.restore()


  describe "#clear", ->

   beforeEach ->
      @view.subviews = [@subview1, @subview2]

    it "destroys subviews", ->
      @subview1.destroy = sinon.spy()
      @subview2.destroy = sinon.spy()
      @view.clear()
      @subview1.destroy.should.have.been.calledOnce
      @subview2.destroy.should.have.been.calledOnce

    it "calls super", ->
      sinon.spy Coreon.Views.SimpleView::, "clear"
      try
        @view.clear()
        Coreon.Views.SimpleView::clear.should.have.been.calledOn @view
      finally
        Coreon.Views.SimpleView::clear.restore()

    it "can be chained", ->
      @view.clear().should.equal @view

  describe "#destroy", ->
    
    beforeEach ->
      @view.subviews = [@subview1, @subview2]

    it "destroys subviews", ->
      @subview1.destroy = sinon.spy()
      @subview2.destroy = sinon.spy()
      @view.destroy()
      @subview1.destroy.should.have.been.calledOnce
      @subview2.destroy.should.have.been.calledOnce
