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
