class Session
  include Mongoid::Document

  field :expired_at, type: Time, default: ->{Time.now + 30 * 24 * 3600}
  field :unavailable, type: Boolean, default: false
  field :create_time, type: Time, default: ->{Time.now}

  belongs_to :user

  def expired?
    expired_at < Time.now
  end

  def refresh
    self.expired_at = Time.now + 30 * 24 * 3600
  end
end