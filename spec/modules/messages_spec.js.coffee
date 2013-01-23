#= require spec_helper
#= require jquery
#= require underscore
#= require backbone
#= require modules/messages

describe "Coreon.Modules.Messages", ->

  beforeEach ->
    @module = Coreon.Modules.Messages

  describe "#message", ->

    beforeEach ->
      @notifications = new Backbone.Collection

      Coreon.application =
        account:
          notifications: @notifications

    afterEach ->
      delete Coreon.application

    it "creates notification", ->
      @module.message "Did you kill the white man who killed you?"
      @notifications.should.have.lengthOf 1
      @notifications.first().get("message").should.equal "Did you kill the white man who killed you?"

    it "takes optional attributes", ->
      @module.message "I am hit!", type: "error"
      @notifications.first().get("type").should.equal "error"
