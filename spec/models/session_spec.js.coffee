#= require spec_helper
#= require models/session

describe "Coreon.Models.Session", ->

  beforeEach ->
    @auth_root = Coreon.Models.Session.auth_root
    Coreon.Models.Session.auth_root = "https://auth.coreon.com"
    sinon.stub localStorage, "getItem"
    sinon.stub localStorage, "removeItem"
    
  afterEach ->
    localStorage.getItem.restore()
    localStorage.removeItem.restore()
    Coreon.Models.Session.auth_root = @auth_root

  describe "class", ->
  
    describe "load()", ->

      context "without local session", ->
        
        beforeEach ->
          localStorage.getItem.withArgs("coreon-session").returns null

        it "passes null to callbacks", ->
          Coreon.Models.Session.load().always (@session) =>
          should.equal @session, null

      context "with local session", ->

        beforeEach ->
          localStorage.getItem.withArgs("coreon-session").returns "0457-a33a403-f562fb6f"
          @request = $.Deferred()
          @session = fetch: sinon.stub().returns @request
          sinon.stub Coreon.Models, "Session", => @session

        afterEach ->
          Coreon.Models.Session.restore()

        it "creates session object", ->
          Coreon.Models.Session.load()
          Coreon.Models.Session.should.have.been.calledOnce
          Coreon.Models.Session.should.have.been.calledWithNew
          Coreon.Models.Session.should.have.been.calledWith 
            auth_token: "0457-a33a403-f562fb6f"

        it "loads session from auth service", ->
          Coreon.Models.Session.load()
          @session.fetch.should.have.been.calledOnce

        it "resolves callbacks with session instance when done", ->
          Coreon.Models.Session.load().always (@arg) =>
          @request.resolve()
          @arg.should.equal @session

        it "resolves callbacks with null on failure", ->
          Coreon.Models.Session.load().always (@arg) =>
          @request.reject()
          should.equal @arg, null

    describe "authenticate()", ->

      beforeEach ->
        sinon.stub Coreon.Models, "Session", =>
          @session = new Backbone.Model
          @request = $.Deferred()
          @session.save = sinon.stub().returns @request
          @session

      afterEach ->
        Coreon.Models.Session.restore()

      it "creates pristine session", ->
        Coreon.Models.Session.authenticate "nobody@blake.com", "se7en!"
        Coreon.Models.Session.should.have.been.calledOnce
        Coreon.Models.Session.should.have.been.calledWithNew
      
      it "saves session overiding data with credentials", ->
        Coreon.Models.Session.authenticate "nobody@blake.com", "se7en!"
        @session.save.should.have.been.calledWith {}, data: "email=nobody%40blake.com&password=se7en!"

      it "resolves promise with session instance when done", ->
        Coreon.Models.Session.authenticate("nobody@blake.com", "se7en!").always (@arg) =>
        @request.resolve()
        @arg.should.equal @session

      it "resolves promise with null on failure", ->
        Coreon.Models.Session.authenticate("nobody@blake.com", "se7en!").always (@arg) =>
        @request.reject()
        should.equal @arg, null
        
          
  describe "instance", ->
    
    beforeEach ->
      @session = new Coreon.Models.Session

    describe "url()", ->

      it "is constructed from auth_root and auth_token", ->
        Coreon.Models.Session.auth_root = "https://my.auth.root"
        @session.set "auth_token", "my-auth-token-1234", silent: on
        @session.url().should.equal "https://my.auth.root/login/my-auth-token-1234"
    
      it "strips trailing slash from auth root", ->
        Coreon.Models.Session.auth_root = "https://my.auth.root/"
        @session.set "auth_token", "my-auth-token-1234", silent: on
        @session.url().should.equal "https://my.auth.root/login/my-auth-token-1234"

    describe "destroy()", ->

      beforeEach ->
        sinon.stub Backbone.Model::, "destroy"

      afterEach ->
        Backbone.Model::destroy.restore()

      it "clears local session", ->
        @session.destroy()
        localStorage.removeItem.should.have.been.calledOnce
        localStorage.removeItem.should.have.been.calledWith "coreon-session"
        
      it "calls super", ->
        @session.destroy()
        Backbone.Model::destroy.should.have.been.calledOnce
