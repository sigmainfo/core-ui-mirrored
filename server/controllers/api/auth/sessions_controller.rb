class Api::Auth::SessionsController < ApplicationController
  Api::Auth::NotAuthenticated = Class.new(StandardError)

  def create
    user = Api::Auth::User.find_by login: params[:login]
    raise Api::Auth::NotAuthenticated unless user.authenticate params[:password]
    render json: {
      ttl: 3600,
      user: {
        _id: user.id,
        acl: nil,
        ldap_user: false,
        login: user.login,
        name: user.name
      },
      auth_token: "#{user.id}-bcddee5ba7e95460-0488d880-af3a-012f-5664-525400b5532a",
      expires_at: "3012-07-13T17:59:22+00:00"
    }, status: 201
  rescue Mongoid::Errors::DocumentNotFound, Api::Auth::NotAuthenticated
    render json: { message: "Could not log in", code: "errors.login.failed" }, status: 404
  end

  def destroy
    render nothing: true, status: 204
  end
end
