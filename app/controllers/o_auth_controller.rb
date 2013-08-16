require 'baidu_api'

class OAuthController < ApplicationController
  layout 'simple'

  def start
    redirect_to BAIDU_CLIENT.auth_code.authorize_url(
                    redirect_uri: oauth_callback_url,
                    scope: 'basic,netdisk'
                )
  end

  def callback
    code = params[:code]
    if code
      token = BAIDU_CLIENT.auth_code.get_token(code, :redirect_uri => oauth_callback_url)
      h_token = token.to_hash
      info = BaiduApi.user_info(h_token)
      name = info['uname']
      uid = info['uid']
      return render template: 'o_auth/failed' if name.nil? or uid.nil?

      user = User.find_or_create_by(
          third_party_id: uid,
          username: name
      )
      user.set_token h_token

      if user.save
        store_session user.create_session
      else
        render template: 'o_auth/failed'
      end
    else
      @code = params[:error]
      render template: 'o_auth/failed'
    end
  end
end
