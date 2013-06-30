#= require spec_helper
#= require helpers/can

describe "Coreon.Helpers.can", ->

  beforeEach ->
    @ability = can: sinon.spy()
    @session = get: sinon.stub().returns(@ability)
    Coreon.application = get:=> @session
    @helper = Coreon.Helpers.can

  it "delegates to ability model", ->
    @helper "foo", {}
    @session.get.should.be.calledOnce
    @session.get.should.be.calledWith "ability"
    @ability.can.should.be.calledOnce
    @ability.can.should.be.calledWith "foo", {}
