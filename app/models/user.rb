class User
  include Mongoid::Document

  field :third_party_id, type: String
  field :username, type: String

  has_many :sessions

  embeds_one :token, class_name: 'Token'

  index third_party_id: 1

  def self.user_from_session(session_id)
    begin
      session = Session.find session_id
      session.expired? or session.unavailable ? nil : session.user
    rescue StandardError => _
      nil
    end
  end

  def set_token(token_hash)
    hash = {
        access_token: token_hash['access_token'] || token_hash[:access_token],
        refresh_token: token_hash['refresh_token'] || token_hash[:refresh_token],
        expired_at: Time.at((token_hash['expires_at'] || token_hash[:expires_at]).to_i),
        source_string: token_hash.to_json
    }
    if token.nil?
      self.create_token(hash)
    else
      token.update_attributes! hash
    end
  end

  def create_session
    session = Session.new
    sessions << session
    session
  end
end