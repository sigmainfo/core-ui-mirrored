#= require spec_helper
#= require collections/digraph

describe "Coreon.Collections.Digraph", ->

  beforeEach ->
    @graph = new Coreon.Collections.Digraph

  it "is a Backbone collection", ->
    @graph.should.be.an.instanceof Backbone.Collection

  describe "initialize()", ->
  
    it "takes option for target ids"

  describe "reset()", ->
    
    it "can be chained", ->
      @graph.reset().should.equal @graph

    it "creates edges", ->
      @graph.reset [
        { _id: "source", targetIds: [ "target" ] }
        { _id: "target" }
      ]
      @graph.edgesIn.should.have.deep.property "target[0].id", "source"

  describe "edgesIn", ->

    it "is empty by default", ->
      @graph.edgesIn.should.be.an "object" 
      @graph.edgesIn.should.be.empty

    context "adding node", ->

      context "with outgoing edges", ->

        it "creates edges from newly added nodes", ->
          @graph.reset [ _id: "target" ], silent: true
          @graph.add [
            { _id: "source_1", targetIds: [ "target" ] }
            { _id: "source_2", targetIds: [ "target" ] }
          ]
          @graph.edgesIn.should.have.deep.property "target[0].id", "source_1"
          @graph.edgesIn.should.have.deep.property "target[1].id", "source_2"
        
        it "ignores edges to unknown nodes", ->
          @graph.reset [ _id: "target" ], silent: true
          @graph.add [
            { _id: "node", targetIds: [ "nobody" ] }
          ]
          @graph.edgesIn.should.be.empty

        it "creates edges to existing nodes", ->
          @graph.reset [ _id: "source", targetIds: [ "target_1", "target_2" ] ], silent: true
          @graph.add _id: "target_1"
          @graph.add _id: "target_2"
          @graph.edgesIn.should.have.deep.property "target_1[0].id", "source"
          @graph.edgesIn.should.have.deep.property "target_2[0].id", "source"

      context "with incoming edges", ->

        it "creates edges from newly added nodes"

        

    context "removing node", ->

      context "with outgoing edges", ->

        beforeEach ->
          @graph.reset [
            { _id: "source", targetIds: [ "target" ] }
            { _id: "target" }
          ], silent: true
      
        it "removes edges to removed nodes", ->
          target = @graph.get "target"
          @graph.remove target
          @graph.edgesIn.should.not.have.property "target"

        it "restores edges after readding a node", ->
          target = @graph.get "target"
          @graph.remove target
          @graph.add target
          @graph.edgesIn.should.have.deep.property "target[0].id", "source"
          
        it "removes edges from removed nodes", ->
          source = @graph.get "source"
          @graph.remove source
          @graph.edgesIn.should.not.have.property "target"

    context "changing targetIds on node", ->

      it "creates edges for added ids", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target_1" ] }
          { _id: "target_1" }
          { _id: "target_2" }
        ], silent: true
        @graph.add _id: "target_2"
        source = @graph.get "source"
        source.set "targetIds", [ "target_1", "target_2" ]
        @graph.edgesIn.should.have.deep.property "target_1[0].id", "source"
        @graph.edgesIn.should.have.deep.property "target_2[0].id", "source"

      it "removes edges for dropped ids", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target_1", "target_2" ] }
          { _id: "target_1" }
          { _id: "target_2" }
        ], silent: true
        source = @graph.get "source"
        source.set "targetIds", [ "target_2" ]
        @graph.edgesIn.should.not.have.property "target_1"
        @graph.edgesIn.should.have.deep.property "target_2[0].id", "source"

  describe "on edges:in", ->

    context "resetting collection", ->
      
      it "does not trigger edges:in:add events", ->
        spy = sinon.spy()
        @graph.on "edges:in:add", spy
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ]
        spy.should.not.have.been.called

      it "does not trigger remove events", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ], silent: true
        spy = sinon.spy()
        @graph.on "edges:in:remove", spy
        @graph.reset []
        spy.should.not.have.been.called

    context "adding node", ->

      it "triggers event on target when added", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
        ], silent: true 
        source = @graph.get "source"
        target = new @graph.model _id: "target"
        spy = sinon.spy()
        target.on "edges:in:add", spy
        @graph.add target
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith target, source

      it "triggers event on target when source is added", ->
        @graph.reset [ _id: "target" ], silent: true 
        source = new @graph.model _id: "source", targetIds: [ "target" ]
        target = @graph.get "target"
        spy = sinon.spy()
        target.on "edges:in:add", spy
        @graph.add source
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith target, source

    context "removing node", ->

      beforeEach ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ], silent: true
        @source = @graph.get "source"
        @target = @graph.get "target"
      
      it "triggers event on target when removed", ->
        spy = sinon.spy()
        @target.on "edges:in:remove", spy
        @graph.remove @target
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith @target, @source

      it "triggers event on target when source is removed", ->
        spy = sinon.spy()
        @target.on "edges:in:remove", spy
        @graph.remove @source
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith @target, @source

    context "changing targetIds on node", ->

      it "triggers event on target when added", ->
        @graph.reset [
          { _id: "source" }
          { _id: "target" }
        ], silent: true 
        source = @graph.get "source"
        target = @graph.get "target"
        spy = sinon.spy()
        target.on "edges:in:add", spy
        source.set targetIds: [ "target" ]
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith target, source

      it "triggers event on target when removed", ->
        @graph.reset [
          { _id: "source", targetIds: [ "target" ] }
          { _id: "target" }
        ], silent: true 
        source = @graph.get "source"
        target = @graph.get "target"
        spy = sinon.spy()
        target.on "edges:in:remove", spy
        source.set targetIds: []
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith target, source
