class Api::Auth::User
  include Mongoid::Document
  include ActiveModel::SecurePassword

  field :name
  field :login
  field :password_digest

  has_secure_password
end
