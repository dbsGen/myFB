class OAuth2::AccessToken
  def to_hash
    hash = {}
    hash.merge self.params
    hash[:access_token] = self.token
    hash[:refresh_token] = self.refresh_token
    hash[:expires_in] = self.expires_in
    hash[:expires_at] = self.expires_at
    hash
  end
end
