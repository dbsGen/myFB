class ApplicationController < ActionController::Base
  protect_from_forgery

  def delete_session
    s = Session.find(current_session)
    s.unavailable = true
    s.save!
    cookies['session_id'] = nil
    session['session_id'] = nil
  end

  def store_session(session)
    cookies['session_id'] = session.id
    session['session_id'] = session.id
  end

  def current_session
    cookies['session_id'] || session['session_id']
  end

  helper_method :current_user, :login?

  def current_user
    if @current_user.nil?
      @current_user = User.user_from_session(current_session)
    end
    @current_user
  end

  def login?
    !current_user.nil?
  end

  protected

  def require_login
    unless login?
      redirect_to root_path
    end
  end

  def require_no_login
    if login?
      redirect_to center_path
    end
  end
end
