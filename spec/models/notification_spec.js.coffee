#= require spec_helper
#= require models/notification

describe "Coreon.Models.Notification", ->

  context "class", ->

    afterEach ->
      Coreon.Models.Notification.collection().reset []

    describe "collection()", ->

      it "defaults to empty collection", ->
        collection = Coreon.Models.Notification.collection()
        collection.should.be.an.instanceof Backbone.Collection
        collection.should.have.lengthOf 0

      it "ensures single collection", ->
        collection = Coreon.Models.Notification.collection()
        Coreon.Models.Notification.collection().should.equal collection


    describe "info()", ->

      beforeEach ->
        @collection = Coreon.Models.Notification.collection()

      it "creates info message", ->
        Coreon.Models.Notification.info "You are being followed, William Blake."
        @collection.should.have.lengthOf 1
        info = @collection.first()
        info.should.be.an.instanceof Coreon.Models.Notification
        info.get("type").should.equal "info"
        info.get("message").should.equal "You are being followed, William Blake."

    describe "error()", ->

      beforeEach ->
        @collection = Coreon.Models.Notification.collection()

      it "creates error message", ->
        Coreon.Models.Notification.error "Shit. You ain't even old enough to smoke."
        @collection.should.have.lengthOf 1
        info = @collection.first()
        info.should.be.an.instanceof Coreon.Models.Notification
        info.get("type").should.equal "error"
        info.get("message").should.equal "Shit. You ain't even old enough to smoke."

  context "instance", ->

    beforeEach ->
      @notification = new Coreon.Models.Notification

    afterEach ->
      @notification.destroy()

    it "is a Backbone model", ->
      @notification.should.be.an.instanceOf Backbone.Model

    describe "destroy()", ->

      beforeEach ->
        @stub Backbone.Model::, "destroy"

      it "is triggered after timeout", ->
        @notification.destroy = @spy()
        @notification.initialize()
        @notification.destroy.should.not.have.been.called
        @clock.tick 6000
        @notification.destroy.should.have.been.calledOnce

      it "calls super", ->
        @notification.destroy()
        Backbone.Model::destroy.should.have.been.calledOnce

      it "clears timeout", ->
        sinon.stub window, "clearTimeout"
        orig = @notification.timeout
        @notification.timeout = 1234
        try
          @notification.destroy()
          window.clearTimeout.should.have.been.calledOnce
          window.clearTimeout.should.have.been.calledWith 1234
        finally
          window.clearTimeout.restore()
          clearTimeout orig
