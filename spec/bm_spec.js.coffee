#= require environment
#= require benchmark

console.log "Benchmarks:"

(new Benchmark.Suite)

  .add "underscore", ->
    _([1,2,3,4,6,8,0]).union [7,8,4,5,6]

  .add "comprehension", ->
    copy = (val for val in [1,2,3,4,6,8,0])
    copy.push val for val in [7,8,4,5,6] if copy.indexOf(val) < 0
    copy

  .on "cycle", (event) ->
    console.log String(event.target)
    console.log event.target

  .on "complete", ->
    console.log "Fastest is #{@filter("fastest").pluck("name")}."

  .run async: true
