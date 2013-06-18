#= require spec_helper
#= require models/session

describe "Coreon.Models.Session", ->

  beforeEach ->
    sinon.stub  Backbone.history, "navigate"
    @auth_root = Coreon.Models.Session.auth_root
    Coreon.Models.Session.auth_root = "https://auth.coreon.com"
    sinon.stub localStorage, "getItem"
    sinon.stub localStorage, "setItem"
    sinon.stub localStorage, "removeItem"
    
  afterEach ->
    localStorage.getItem.restore()
    localStorage.setItem.restore()
    localStorage.removeItem.restore()
    Coreon.Models.Session.auth_root = @auth_root
    Backbone.history.navigate.restore()

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

    describe "set()", ->

      beforeEach ->
        @session.set "repositories", [
          id: "nobody-repo-123"
          name: "Nobody's Repository"
        ], silent: yes
        sinon.spy Backbone.Model::, "set"

      afterEach ->
        Backbone.Model::set.restore()

      it "delegates to super", ->
        @session.set {foo: "bar"}, silent: yes
        Backbone.Model::set.should.have.been.calledOnce
        Backbone.Model::set.should.have.been.calledWith { foo: "bar" }, silent: yes

      it "converts to attributes hash", ->
        @session.set "foo", "bar", silent: yes
        Backbone.Model::set.should.have.been.calledWith { foo: "bar" }, silent: yes

      it "selects first repo if given is not available", ->
        @session.set "repositories", [ id: "nobody-repo-123" ]
        @session.set "current_repository_id", "hands-off-123"
        Backbone.Model::set.should.have.been.calledWith current_repository_id: "nobody-repo-123" 

      it "passes null when repositories are empty", ->
        @session.set "repositories", [], silent: yes
        @session.set "current_repository_id", "some-repo-789"
        Backbone.Model::set.should.have.been.calledWith current_repository_id: null

      it "selects first available repo passing in new selection", ->
        @session.set
          current_repository_id: "some-repo-789"
          repositories: [ id: "some-repo-789" ]
        Backbone.Model::set.should.have.been.calledWith
          current_repository_id: "some-repo-789"
          repositories: [ id: "some-repo-789" ]
      
      it "selects first available repo", ->
        @session.set "current_repository_id", "nobody-repo-123", silent: yes
        @session.set "repositories", [ id: "my-new-repo-678" ]
        Backbone.Model::set.should.have.been.calledWith
          repositories: [ id: "my-new-repo-678" ]
          current_repository_id: "my-new-repo-678"

    describe "currentRepository()", ->

      beforeEach ->
        @session.set "repositories", [
          {
            id: "nobody-repo-123"
            name: "Nobody's Repository"
          }
          {
            id: "nobody-repo-124" 
            name: "Nobody's Other Repository"
          }
          {
            id: "nobody-repo-125" 
            name: "Nobody's Repo III"
          }
        ], silent: yes
        @session.set "current_repository_id", "nobody-repo-124", silent: true
        @session.currentRepository()
      
      it "creates repository matching id", ->
        @session.set "current_repository_id", "nobody-repo-125", silent: true
        repo = @session.currentRepository()
        repo.should.be.an.instanceof Coreon.Models.Repository
        repo.should.have.property "id",  "nobody-repo-125"
        repo.get("name").should.equal "Nobody's Repo III"

      it "creates repository only once", ->
        @session.set "current_repository_id", "nobody-repo-125", silent: true
        repo = @session.currentRepository()
        @session.currentRepository().should.equal repo

      it "returns null when none is selected", ->
        @session.set "repositories", [], silent: true
        should.equal @session.currentRepository(), null

    describe "onChangeToken()", ->

      it "is triggered by changes on token", ->
        @session.onChangeToken = sinon.spy()
        @session.initialize()
        @session.trigger "change:auth_token", @session, "my-brandnew-token-123"
        @session.onChangeToken.should.have.been.calledOnce 
        @session.onChangeToken.should.have.been.calledWith @session, "my-brandnew-token-123"
     
      it "saves token locally", ->
        @session.onChangeToken @session, "my-brandnew-token-123"
        localStorage.setItem.should.have.been.calledOnce
        localStorage.setItem.should.have.been.calledWith "coreon-session", "my-brandnew-token-123"

      it "clears token locally", ->
        @session.onChangeToken @session, ""
        localStorage.setItem.should.not.have.been.called
        localStorage.removeItem.should.have.been.calledOnce
        localStorage.removeItem.should.have.been.calledWith "coreon-session" 

      it "navigates to repo root", ->
        @session.onChangeToken @session, "my-brandnew-token-123"
        Backbone.history.navigate.should.have.been.calledOnce
        Backbone.history.navigate.should.have.been.calledWith "my-brandnew-token-123", trigger: yes
        
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
