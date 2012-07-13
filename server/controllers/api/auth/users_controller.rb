class Api::Auth::UsersController < ApplicationController
  def create
    user = ::Api::Auth::User.create! params["user"]
    render json: user, status: 201
  end

  def purge
    ::Api::Auth::User.delete_all
    render json: {message: "I'm not dead. Am I?"}
  end
end
