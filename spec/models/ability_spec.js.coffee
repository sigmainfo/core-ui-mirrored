#= require spec_helper
#= require models/ability

describe "Coreon.Models.Ability", ->

  beforeEach ->
    @ability = new Coreon.Models.Ability
    
  it "is a Backbone model", ->
    @ability.should.be.an.instanceof Backbone.Model

  it "defaults role to user", ->
    should.exist @ability.get "role"
    @ability.get("role").should.eql "user"

  describe "can()", ->
  
    it "denies everything by default", ->
      @ability.can("post", {}).should.be.false

    context "as a user", ->

      beforeEach ->
        @ability.set "role", "user"
      
      it "can read everything", ->
        @ability.can("read", {}).should.be.true

      it "cannot create a Concept", ->
        @ability.can("create", Coreon.Models.Concept).should.be.false

    context "as a maintainer", ->
      
      beforeEach ->
        @ability.set "role", "maintainer"

      it "can read everything", ->
        @ability.can("read", {}).should.be.true

      it "cannot create a Concept", ->
        @ability.can("create", Coreon.Models.Concept).should.be.true
