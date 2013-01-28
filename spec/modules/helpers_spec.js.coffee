#= require spec_helper
#= require modules/helpers

describe "Coreon.Modules", ->


  describe "extend", ->

    beforeEach ->
      @target = name: "target"

    it "returns target", ->
      Coreon.Modules.extend(@target, {}).should.equal @target
     
    it "copy properties from module to target", ->
      Coreon.Modules.extend @target, foo: "bar"
      @target.should.have.property "foo", "bar"

    it "takes multiple modules", ->
      Coreon.Modules.extend @target, { foo: "bar" }, { bar: "baz" }
      @target.should.have.property "foo", "bar"
      @target.should.have.property "bar", "baz"
      
  describe "include", ->
  
    beforeEach ->
      @target = class Target
        name: "target"

    afterEach ->
      Traget = null

    it "returns target", ->
      Coreon.Modules.include(@target, {}).should.equal @target

    it "copy properties from module to target prototype", ->
      Coreon.Modules.include @target, foo: "bar"
      @target::.should.have.property "foo", "bar"

    it "takes multiple modules", ->
      hook = sinon.spy()
      Coreon.Modules.include @target, { foo: "bar" }, { bar: "baz" }
      @target::.should.have.property "foo", "bar"
      @target::.should.have.property "bar", "baz"
