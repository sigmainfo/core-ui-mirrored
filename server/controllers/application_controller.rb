class ApplicationController < ActionController::Base

  private

  Api::Graph::NotAuthenticated = Class.new(StandardError)

  def authenticate
    unless Api::Auth::User.where(id: request.headers["X-Core-Session"][0...24]).exists?
      render json: {
      }, status: 403
    end
  end
end
