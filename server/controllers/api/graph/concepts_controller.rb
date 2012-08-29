class Api::Graph::ConceptsController < ApplicationController
  Api::Graph::NotAuthenticated = Class.new(StandardError)

  before_filter :authenticate

  def search
    sleep Random.rand(0.2..2)
    render json: {
      hits: []
    }
  end

  private

  def authenticate
    unless Api::Auth::User.where(id: request.headers["X-Core-Session"][0...24]).exists?
      render json: {
      }, status: 403
    end
  end
end
