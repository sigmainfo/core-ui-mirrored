#= require spec_helper
#= require views/composite_view

describe "Coreon.Views.CompositeView", ->

  beforeEach ->
    @view = new Coreon.Views.CompositeView
    @subview = @subview1 = new Coreon.Views.SimpleView className: "subview", id: "subview1"
    @subview2 = new Coreon.Views.SimpleView className: "subview", id: "subview2"

  afterEach ->
    view.destroy() for view in [@view, @subview1, @subview2]

  it "is a Coreon view", ->
    @view.should.be.an.instanceof Coreon.Views.SimpleView

  it "creates an empty subview collection by default", ->
    @view.subviews.should.eql []

  describe "#add", ->
    
    it "adds view to subviews", ->
      @view.add @subview
      @view.subviews.should.have.length 1
      @view.subviews[0].should.equal @subview

    it "adds view only once", ->
      @view.add @subview
      @view.add @subview
      @view.subviews.should.have.length 1
      @view.subviews[0].should.equal @subview

    it "takes multiple views simultaneously", ->
      @view.add @subview1, @subview2
      @view.subviews.should.eql [@subview1, @subview2]

  describe "#drop", ->

    beforeEach ->
      @view.add @subview1, @subview2
    
    it "removes view from subviews", ->
      @view.drop @subview2
      @view.subviews.should.eql [@subview1]

    it "takes multiple arguments", ->
      @view.drop @subview2, @subview1
      @view.subviews.should.eql []
    

  describe "#append", ->
    
    it "adds subview to collection", ->
      @view.append @subview
      @view.subviews.should.eql [@subview]

    it "appends el", ->
      @view.append @subview
      @view.$el.should.have ".subview"

    it "appends el to matching node", ->
      @view.$el.append $("<div>").addClass("target")
      @view.append ".target", @subview
      @view.$(".target").should.have ".subview"

    it "calls delegateEvents on subview", ->
      @subview.delegateEvents = sinon.spy()
      @view.append @subview
      @subview.delegateEvents.should.have.been.calledOnce

    it "takes multiple subviews as arguments", ->
      @view.append @subview1, @subview2
      @view.$el.should.have "#subview1"
      @view.$el.should.have "#subview2"

  describe "#prepend", ->

    it "adds subview to collection", ->
      @view.prepend @subview
      @view.subviews.should.eql [@subview]

    it "prepends el", ->
      @view.$el.prepend = sinon.spy()
      @view.prepend @subview
      @view.$el.prepend.should.have.been.calledWith @subview.$el

    it "prepends el to matching node", ->
      @view.$el.append $("<div>").addClass("target")
      @view.prepend ".target", @subview
      @view.$(".target").should.have ".subview"

    it "calls delegateEvents on subview", ->
      @subview.delegateEvents = sinon.spy()
      @view.prepend @subview
      @subview.delegateEvents.should.have.been.calledOnce

    it "takes multiple subviews as arguments", ->
      @view.prepend @subview1, @subview2
      @view.$el.should.have "#subview1"
      @view.$el.should.have "#subview2"

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

    it "clears subview references", ->
      @view.clear()
      @view.subviews.should.eql []

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
