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

do -> # clobber context
  keep = null

  beforeEach ->
    keep = (name for name, value of @)

  afterEach ->
    delete @[name] for name, value of @ when name not in keep
