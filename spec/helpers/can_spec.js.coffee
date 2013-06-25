#= require spec_helper
#= require helpers/can

describe "Coreon.Helpers.can", ->

  beforeEach ->
    Coreon.application = new Backbone.Model
    @helper = Coreon.Helpers.can

  context "no session", ->
    beforeEach ->
      Coreon.application.set "session", null

    it "returns false without any session", ->
      @helper("read", Object).should.be.false
      @helper("edit", Object).should.be.false
      @helper("delete", Object).should.be.false

  context "without user or maintainer rights", ->
    beforeEach ->
      Coreon.application.set "session", highestRole: -> null

    it "returns false on anything", ->
      @helper("read", Object).should.be.false
      @helper("edit", Object).should.be.false
      @helper("delete", Object).should.be.false

  context "as a user", ->
    beforeEach ->
      Coreon.application.set "session", highestRole: -> "user"

    it "returns true on read", ->
      @helper("read", Object).should.be.true

    it "returns false on anything except read", ->
      @helper("edit", Object).should.be.false
      @helper("delete", Object).should.be.false

  context "as a maintainer", ->
    beforeEach ->
      Coreon.application.set "session", highestRole: -> "maintainer"

    it "returns true on anything", ->
      @helper("read", Object).should.be.true
      @helper("edit", Object).should.be.true
      @helper("delete", Object).should.be.true
