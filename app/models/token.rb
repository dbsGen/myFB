class Token
  include Mongoid::Document

  field :access_token, type: String
  field :refresh_token, type: String
  field :expired_at, type: Time
  field :source_string, type: String
  field :available, type: Boolean, default: true

  embedded_in :user

  index access_token: 1

  def token_object
    OAuth2::AccessToken.from_hash(BAIDU_CLIENT, source)
  end

  def source
    JSON(source_string)
  end

  def source=(json)
    self.source_string = json.to_json
  end
end