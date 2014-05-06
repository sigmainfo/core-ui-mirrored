#= require spec_helper
#= require modules/error_notifications

describe "Coreon.Modules.ErrorNotifications", ->

  describe "failHandler", ->

    beforeEach ->
      @stub Coreon.Models.Notification, "error"
      @xhr = status: 404, responseText: "{}"

    it "creates generic error message", ->
      I18n.t.withArgs("errors.generic").returns "An error occured."
      I18n.t.withArgs(undefined, defaultValue: "An error occured.").returns "An error occured."
      Coreon.Modules.ErrorNotifications.failHandler @xhr, "error", "Not found"
      Coreon.Models.Notification.error.should.have.been.calledOnce
      Coreon.Models.Notification.error.should.have.been.calledWith "An error occured."

    it "defers translation from response", ->
      I18n.t.withArgs("errors.login.failed").returns "Could not log in."
      @xhr.responseText = '{"code":"errors.login.failed","message":"Password or email invalid!"}'
      Coreon.Modules.ErrorNotifications.failHandler @xhr, "error", "Not found"
      Coreon.Models.Notification.error.should.have.been.calledOnce
      Coreon.Models.Notification.error.should.have.been.calledWith "Could not log in."

    it "falls back to message from response when no translation given", ->
      I18n.t.withArgs("errors.login.failed", defaultValue: "Password or email invalid!").returns "Password or email invalid!"
      @xhr.responseText = '{"code":"errors.login.failed","message":"Password or email invalid!"}'
      Coreon.Modules.ErrorNotifications.failHandler @xhr, "error", "Not found"
      Coreon.Models.Notification.error.should.have.been.calledOnce
      Coreon.Models.Notification.error.should.have.been.calledWith "Password or email invalid!"

    it "falls back to message from response when no code given", ->
      @xhr.responseText = '{"message":"Password or email invalid!"}'
      Coreon.Modules.ErrorNotifications.failHandler @xhr, "error", "Not found"
      Coreon.Models.Notification.error.should.have.been.calledOnce
      Coreon.Models.Notification.error.should.have.been.calledWith "Password or email invalid!"

    it "creates error message when service is unavailable", ->
      I18n.t.withArgs("errors.service.unavailable").returns "Service unavailable."
      @xhr.status = 0
      Coreon.Modules.ErrorNotifications.failHandler @xhr, "error", ""
      Coreon.Models.Notification.error.should.have.been.calledOnce
      Coreon.Models.Notification.error.should.have.been.calledWith "Service unavailable."

    it "creates no error message when unauthorized", ->
      @xhr.status = 403
      Coreon.Modules.ErrorNotifications.failHandler @xhr, "error", ""
      Coreon.Models.Notification.error.should.not.have.been.called


