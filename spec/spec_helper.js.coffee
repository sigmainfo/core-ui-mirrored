#= require environment
#= require jquery
#= require sinon
#= require sinon-chai
#= require chai-jquery
#= require environment

jQuery.fx.off = true

keep = null
beforeEach ->
  keep = (name for name, value of @)
afterEach ->
  delete @[name] for name, value of @ when name not in keep
