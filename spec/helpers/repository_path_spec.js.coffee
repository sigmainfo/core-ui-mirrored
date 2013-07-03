#= require spec_helper
#= require helpers/repository_path

describe "Coreon.Helpers.repository_path()", ->
  beforeEach ->
    @helper = Coreon.Helpers.repositoryPath
    Coreon.application = new Backbone.Model
      session: new Backbone.Model current_repository_id:"coffeebabe23coffeebabe42"

  it "strips trailing slashes", ->
    @helper().should.equal "/coffeebabe23coffeebabe42"

  it "prefixes with repository id", ->
    @helper("foo").should.equal "/coffeebabe23coffeebabe42/foo"

  xit "joins multiple fragments", ->
    @helper("1", "2", "3").should.equal "/coffeebabe23coffeebabe42/1/2/3"

  it "avoids multiple slashes", ->
    @helper("/1/").should.equal "/coffeebabe23coffeebabe42/1/"

