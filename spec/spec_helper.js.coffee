#= require environment
#= require jquery
#= require sinon
#= require sinon-chai
#= require chai-jquery
#= require environment

jQuery.fx.off = true

do -> #set up sinon sandbox
  sandbox = null

  beforeEach ->
    sandbox = sinon.sandbox.create
      injectInto: @
      properties: ['spy', 'stub', 'mock', 'clock', 'server', 'requests']
      useFakeTimers: on
      useFakeServer: on

  afterEach ->
    sandbox.restore()

do -> # stub all translations

  beforeEach ->
    @stub I18n, 't'

do -> # clobber context
  keep = null

  beforeEach ->
    keep = (name for name, value of @)

  afterEach ->
    delete @[name] for name, value of @ when name not in keep

chai.use (chai, utils) -> # custom matchers

  chai.Assertion.addProperty 'emptyArray', ->
    obj = utils.flag @, 'object'
    new chai.Assertion(obj).to.be.empty
    new chai.Assertion(obj).to.be.instanceof Array

  chai.Assertion.addMethod 'deepCopyOf', (original) ->
    obj = utils.flag @, 'object'

    new chai.Assertion(obj).to.be.instanceOf original.constructor

    originalModels = original.models or [original]
    copiedModels   = obj.models      or [obj]

    new chai.Assertion(copiedModels).to.have.lengthOf originalModels.length

    originalModels.forEach (original, index) ->
      originalAttrs = original.attributes
      copy = copiedModels[index]
      copiedAttrs = copy.attributes
      new chai.Assertion(copiedAttrs).to.not.equal originalAttrs
      new chai.Assertion(copiedAttrs).to.eql originalAttrs

  chai.Assertion.addMethod 'childOf', (parent) ->
    obj = utils.flag @, 'object'
    parentNode = $(parent)[0]
    childNode  = $(obj)[0]
    assertion = new chai.Assertion
    utils.transferFlags @, assertion, no
    expectation = if utils.flag @, 'negation' then no else yes
    assertion.assert $.contains(parentNode, childNode) is expectation
                  , "Expected #{childNode} to be a child node of #{parentNode}"
                  , "Expected #{childNode} to not be a child node of #{parentNode}"
