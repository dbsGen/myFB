require 'baidu_api'

class MainController < ApplicationController
  before_filter :require_no_login, only: :home
  before_filter :require_login, only: [:center, :images, :upload]

  IMAGE_DIR = 'images'

  def home

  end

  def logout
    begin
      delete_session
    ensure
      redirect_to root_path
    end
  end

  def center
  end

  def upload
    file = params[:file]
    if file.content_type[/^image/]
      url = BaiduApi.upload(current_user.token.source, "/#{IMAGE_DIR}/#{Time.now.to_i}#{file.original_filename[/\.[^\.]*$/]}")
      client = HTTPClient.new
      response = client.post(url, {file: file.tempfile})
      begin
        json = JSON(response.body)
        if json['error_code']
          render status: 500, json: json
        else
          render json: {
              list: [{
                         fs_id: json['fs_id'],
                         url: image_url(current_user.third_party_id, json['path'][/[^\/]+$/]),
                         ctime: json['ctime'],
                         mtime: json['mtime']
                     }]
          }
        end
      rescue StandardError => e
        render status: 500, json: {code: 200, msg: 'Upload failed'}
      end
    else
      render status: 500, json: {code: 500, msg: 'It is not a image'}
    end
  end

  def images
    respond_to do |format|
      format.json do
        render status: 500, json:{code: 500, msg: '授权失效'} unless check_token(current_user)
        result = BaiduApi.files(current_user.token.source, "/#{IMAGE_DIR}")
        if result['error_code']
          # 没有这个目录
          ret = {list: []}
        else
          list = []
          result['list'].each do |item|
            list << {
                fs_id: item['fs_id'],
                url: image_url(current_user.third_party_id, item['path'][/[^\/]+$/]),
                ctime: item['ctime'],
                mtime: item['mtime']
            }
          end
          ret = {list: list}
        end
        render json: ret
      end
    end
  end

  def remove
    file = params[:file]
    format = params[:format]
    render status: 500, json:{code: 500, msg: '授权失效'} unless check_token(current_user)
    uri = BaiduApi.delete(current_user.token.source, "/#{IMAGE_DIR}/#{file}.#{format}")
    begin
      result = JSON(HTTPClient.post(uri).body)
      if result['error_code']
        render status: 500, json: {code: 500, msg: 'Delete failed'}
      else
        render json: {code: 200, msg: 'Delete success!'}
      end
    rescue StandardError => _
      render status: 500, json: {code: 500, msg: 'Delete failed'}
    end
  end

  def image
    uid = params[:uid]
    file = params[:file]
    format = params[:format]
    user = User.find_by(third_party_id: uid.to_s)
    render status: 500, json:{code: 500, msg: '授权失效'} unless check_token(user)
    redirect_to BaiduApi.download(user.token.source, "/#{IMAGE_DIR}/#{file}.#{format}")
  end

  private
  def check_token(user)
    token = user.token
    return false unless token.available
    token_object = token.token_object
    if token_object.expired?
      begin
        new_token = token_object.refresh!
        user.set_token(new_token.to_hash)
        user.save
      rescue StandardError => e
        logger.error "#### : Can not refresh the token on user #{user}: #{e}"
        token.available = false
        token.save
        return false
      end
    end
    true
  end
end
