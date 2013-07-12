#= require spec_helper
#= require helpers/can

describe "Coreon.Helpers.can", ->

  beforeEach ->
    @ability = can: sinon.spy()
    @session = ability:=> @ability
    Coreon.application = get:=> @session
    @helper = Coreon.Helpers.can

  it "delegates to ability model", ->
    @helper "foo", {}
    @ability.can.should.be.calledOnce
    @ability.can.should.be.calledWith "foo", {}
