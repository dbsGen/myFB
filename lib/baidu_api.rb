require 'customer'
class AccessTokenInvalid < StandardError; end

class BaiduApi
  def self.user_info(token)
    client = HTTPClient.new()
    user_info = client.post(BAIDU_SITE + BAIDU_USER_PATH, 'access_token' => token[:access_token] || token['access_token'])
    JSON(user_info.body)
  end

  # 返回数据的格式
  #"list":[{"fs_id":3528850315,
  #    "path":"/apps/yunform/music/hello",
  #    "ctime":1331184269,
  #    "mtime":1331184269,
  #    "block_list":["59ca0efa9f5633cb0371bbc0355478d8"],
  #    "size":13,
  #    "isdir":0
  #}],
  #"request_id":4043312670
  def self.files(token, folder)
    client = HTTPClient.new()
    params = {
        :method => 'list',
        :access_token => token[:access_token] || token['access_token'],
        :path => "#{BAIDU_ROOT_FOLDER}#{folder}",
        :by => 'time',
        :order => 'desc'
    }
    response = client.get(BAIDU_PCS_SITE + BAIDU_FILES, params)
    check_result JSON(response.body)
  end

  #上传部分写到js里面这里只拼出url
  #这样文件流量不用经过我们的服务器
  def self.upload(token, path, ondup = 'overwrite')
    path = "#{BAIDU_ROOT_FOLDER}#{path}"
    params = {
        :method => 'upload',
        :access_token => token[:access_token] || token['access_token'],
        :path => path,
        :ondup => ondup
    }
    p = URI::Parser.new
    uri = p.parse(BAIDU_UPLOAD_SITE + BAIDU_FILES)
    uri.query = params.to_query
    uri
  end

  def self.delete(token, path)
    path = "#{BAIDU_ROOT_FOLDER}#{path}"
    params = {
        :method => 'delete',
        :access_token => token[:access_token] || token['access_token'],
        :path => path
    }
    p = URI::Parser.new
    uri = p.parse(BAIDU_UPLOAD_SITE + BAIDU_FILES)
    uri.query = params.to_query
    uri
  end

  #只拼出url下载到个人机器上，这样流量不用通过服务器
  def self.download(token, path)
    path = "#{BAIDU_ROOT_FOLDER}#{path}"
    params = {
        :method => 'download',
        :access_token => token[:access_token] || token['access_token'],
        :path => path
    }
    p = URI::Parser.new
    uri = p.parse(BAIDU_PCS_SITE + BAIDU_FILES)
    uri.query = params.to_query
    uri.to_s
  end

  def self.refresh_token(token, client)
    access_token = OAuth2::AccessToken.from_hash(client, token)
    access_token.refresh!
    access_token.to_hash
  end

  private
  def self.check_result(result)
    case result['error_code'].to_i
      when 0
        result
      when 110
        raise AccessTokenInvalid
      else
        result
    end
  end
end