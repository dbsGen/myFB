BAIDU_ROOT_FOLDER = '/apps/myfb'

BAIDU_SITE = 'https://openapi.baidu.com'
BAIDU_USER_PATH = '/rest/2.0/passport/users/getLoggedInUser'

BAIDU_PCS_SITE = 'https://pcs.baidu.com'
BAIDU_UPLOAD_SITE = 'https://c.pcs.baidu.com'
BAIDU_FILES = '/rest/2.0/pcs/file'

BAIDU_CLIENT = OAuth2::Client.new(
    'ktbAzfKnYp5vTh9fbL3bXOIB',
    'KIIHsRl9BCrCxpD9vXnw4FzbkBch1u2Z',
    :site => BAIDU_SITE,
    :authorize_url => '/oauth/2.0/authorize',
    :token_url => '/oauth/2.0/token'
)
