#= require spec_helper
#= require models/ability

describe "Coreon.Models.Ability", ->

  beforeEach ->
    @repo = new Backbone.Model user_roles:[]
    @session =
      currentRepository: => @repo
    @ability = new Coreon.Models.Ability @session

  it "is a Backbone model", ->
    @ability.should.be.an.instanceof Backbone.Model

  it "denies everything by default", ->
    @ability.can("post", {}).should.be.false

  context "as a user", ->

    beforeEach ->
      @repo.set "user_roles", [ "user" ]

    it "can read everything", ->
      @ability.can("read", {}).should.be.true

    it "cannot create a Concept", ->
      @ability.can("create", Coreon.Models.Concept).should.be.false

  context "as a maintainer", ->

    beforeEach ->
      @repo.set "user_roles", [ "user", "maintainer" ]

    it "can read everything", ->
      @ability.can("read", {}).should.be.true

    it "can create a Concept", ->
      @ability.can("create", Coreon.Models.Concept).should.be.true
