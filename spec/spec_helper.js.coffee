#= require jquery
#= require jquery.simulate
#= require sinon
#= require sinon-chai
#= require chai-jquery

jQuery.fx.off = true

after ->
  localStorage.removeItem Coreon.Models.Session::options.sessionId if Coreon.Models.Session?
