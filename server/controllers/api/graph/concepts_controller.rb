class Api::Graph::ConceptsController < ApplicationController
  Api::Graph::NotAuthenticated = Class.new(StandardError)

  def search
    sleep Random.rand(0.2..2)
    render json: {
      hits: []
    }
  end
end
