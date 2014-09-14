require_relative 'test_helper.rb'

class AuthTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Rack::Test::Utils

  def app; App; end

  def test_invalid_token_creating_link
    get('/api?url=http://test.com')            && assert_unauthorized
    get('/api?token=&url=http://test.com')     && assert_unauthorized
    get('/api?token=test&url=http://test.com') && assert_unauthorized
  end

  def test_invalid_token_creating_media
    post('/api',            'media' => image) && assert_unauthorized
    post('/api?token=',     'media' => audio) && assert_unauthorized
    post('/api?token=test', 'media' => zip)   && assert_unauthorized
    post('/api?token=test', 'media' => pdf)   && assert_unauthorized
    post('/api?token=test', 'media' => video) && assert_unauthorized
  end

  def test_invalid_token_deleting
    delete('/api?slug=test')         && assert_unauthorized
    get('/api?token=&slug=test')     && assert_unauthorized
    get('/api?token=test&slug=test') && assert_unauthorized
  end

  def test_invalid_login_accessing_admin
    authorize('', '')         && get('/admin') && assert_unauthorized
    authorize('user', 'test') && get('/admin') && assert_unauthorized
    authorize('test', 'pass') && get('/admin') && assert_unauthorized
    authorize('test', 'test') && get('/admin') && assert_unauthorized
  end
end